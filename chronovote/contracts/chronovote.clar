;; ChronoVote: Dynamic Time-Weighted Governance System
;; A governance system where voting power scales with token holding duration

;; Traits
(define-trait governance-token-trait 
    ((transfer (uint principal principal (optional (buff 34))) (response bool uint))
     (get-balance (principal) (response uint uint))))

;; Constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_MOTION (err u101))
(define-constant ERR_MOTION_ACTIVE (err u102))
(define-constant ERR_MOTION_ENDED (err u103))
(define-constant ERR_ALREADY_CAST (err u104))
(define-constant ERR_INSUFFICIENT_STAKE (err u105))
(define-constant ERR_TOKEN_NOT_SET (err u106))
(define-constant ERR_MOTION_NOT_ENDED (err u107))
(define-constant ERR_THRESHOLD_NOT_MET (err u108))
(define-constant ERR_MOTION_ALREADY_FINALIZED (err u109))
(define-constant ERR_NO_VOTE_TO_REVOKE (err u110))
(define-constant ERR_WITHDRAWAL_EXCEEDS_STAKE (err u111))

(define-constant MOTION_DURATION u144) ;; ~24 hours in blocks
(define-constant MIN_MOTION_STAKE u100000000) ;; Minimum tokens needed to create motion
(define-constant TIME_MULTIPLIER u100) ;; Base multiplier for voting power calculations
(define-constant MAX_TIME_BONUS u300) ;; Maximum 3x voting power multiplier
(define-constant MIN_PARTICIPATION u500000000) ;; Minimum total votes required for a motion to pass

;; Data Variables
(define-data-var motion-count uint u0)
(define-data-var governance-token (optional principal) none)
(define-data-var admin principal tx-sender)

;; Maps
(define-map Motions
    {id: uint}
    {
        creator: principal,
        title: (string-ascii 50),
        description: (string-ascii 500),
        start-height: uint,
        end-height: uint,
        yea-count: uint,
        nay-count: uint,
        finalized: bool,
        threshold: uint
    }
)

(define-map Stakes
    {participant: principal}
    {
        amount: uint,
        stake-height: uint
    }
)

(define-map Ballots
    {motion-id: uint, voter: principal}
    {weight: uint, approve: bool}
)

;; Private Functions
(define-private (calculate-weight (participant principal))
    (let (
        (stake (default-to {amount: u0, stake-height: block-height} (map-get? Stakes {participant: participant})))
        (blocks-staked (- block-height (get stake-height stake)))
        (base-weight (get amount stake))
        (raw-bonus (* TIME_MULTIPLIER (/ blocks-staked u1440))) ;; 1 day = ~1440 blocks
        (time-bonus (if (> raw-bonus MAX_TIME_BONUS) 
            MAX_TIME_BONUS
            raw-bonus))
    )
    (/ (* base-weight (+ TIME_MULTIPLIER time-bonus)) TIME_MULTIPLIER))
)

(define-private (check-motion-status (motion-id uint))
    (let (
        (motion (unwrap! (map-get? Motions {id: motion-id}) ERR_INVALID_MOTION))
        (total-votes (+ (get yea-count motion) (get nay-count motion)))
    )
        (asserts! (>= block-height (get end-height motion)) ERR_MOTION_NOT_ENDED)
        (asserts! (not (get finalized motion)) ERR_MOTION_ALREADY_FINALIZED)
        (asserts! (>= total-votes (get threshold motion)) ERR_THRESHOLD_NOT_MET)
        (ok motion)
    )
)

;; Public Functions
(define-public (set-governance-token (new-token principal))
    (begin
        (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
        (ok (var-set governance-token (some new-token)))
    )
)

(define-public (stake-tokens (token-trait <governance-token-trait>) (amount uint))
    (let (
        (token (unwrap! (var-get governance-token) ERR_TOKEN_NOT_SET))
    )
        (asserts! (is-eq (contract-of token-trait) token) ERR_UNAUTHORIZED)
        (try! (contract-call? token-trait transfer 
            amount 
            tx-sender 
            (as-contract tx-sender) 
            none))
        (map-set Stakes 
            {participant: tx-sender}
            {
                amount: (+ (default-to u0 (get amount (map-get? Stakes {participant: tx-sender}))) amount),
                stake-height: block-height
            }
        )
        (ok true)
    )
)

(define-public (unstake-tokens (token-trait <governance-token-trait>) (amount uint))
    (let (
        (token (unwrap! (var-get governance-token) ERR_TOKEN_NOT_SET))
        (stake (default-to {amount: u0, stake-height: u0} (map-get? Stakes {participant: tx-sender})))
    )
        (asserts! (is-eq (contract-of token-trait) token) ERR_UNAUTHORIZED)
        (asserts! (<= amount (get amount stake)) ERR_WITHDRAWAL_EXCEEDS_STAKE)
        (try! (as-contract (contract-call? token-trait transfer 
            amount 
            tx-sender 
            tx-sender 
            none)))
        (map-set Stakes 
            {participant: tx-sender}
            {
                amount: (- (get amount stake) amount),
                stake-height: (get stake-height stake)
            }
        )
        (ok true)
    )
)

(define-public (create-motion (title (string-ascii 50)) (description (string-ascii 500)))
    (let (
        (creator-weight (calculate-weight tx-sender))
        (new-id (+ (var-get motion-count) u1))
    )
        (asserts! (>= creator-weight MIN_MOTION_STAKE) ERR_INSUFFICIENT_STAKE)
        (map-set Motions 
            {id: new-id}
            {
                creator: tx-sender,
                title: title,
                description: description,
                start-height: block-height,
                end-height: (+ block-height MOTION_DURATION),
                yea-count: u0,
                nay-count: u0,
                finalized: false,
                threshold: MIN_PARTICIPATION
            }
        )
        (var-set motion-count new-id)
        (ok new-id)
    )
)

(define-public (cast-vote (motion-id uint) (approve bool))
    (let (
        (motion (unwrap! (map-get? Motions {id: motion-id}) ERR_INVALID_MOTION))
        (voter-weight (calculate-weight tx-sender))
    )
        (asserts! (< block-height (get end-height motion)) ERR_MOTION_ENDED)
        (asserts! (is-none (map-get? Ballots {motion-id: motion-id, voter: tx-sender})) ERR_ALREADY_CAST)
        (map-set Ballots
            {motion-id: motion-id, voter: tx-sender}
            {weight: voter-weight, approve: approve}
        )
        (map-set Motions
            {id: motion-id}
            (merge motion 
                {
                    yea-count: (if approve (+ (get yea-count motion) voter-weight) (get yea-count motion)),
                    nay-count: (if (not approve) (+ (get nay-count motion) voter-weight) (get nay-count motion))
                }
            )
        )
        (ok true)
    )
)

(define-public (finalize-motion (motion-id uint))
    (let (
        (motion (try! (check-motion-status motion-id)))
        (yea-count (get yea-count motion))
        (nay-count (get nay-count motion))
    )
        (map-set Motions
            {id: motion-id}
            (merge motion {finalized: true})
        )
        (print {
            motion-id: motion-id,
            result: (if (> yea-count nay-count) "passed" "rejected"),
            yea-count: yea-count,
            nay-count: nay-count
        })
        (ok true)
    )
)