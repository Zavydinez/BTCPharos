

;; BTCPharps - Bitcoin-Backed Lending Protocol on Stacks Blockchain
;; <add a description here>

(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u2))
(define-constant ERR-LOAN-NOT-FOUND (err u3))
(define-constant ERR-LOAN-ALREADY-ACTIVE (err u4))
(define-constant ERR-INVALID-INPUT (err u5))
(define-constant ERR-INSUFFICIENT-EXCESS-COLLATERAL (err u6))
(define-constant ERR-LOAN-ALREADY-LIQUIDATED (err u7))

;; traits
;;
;; Liquidation-specific constants
(define-constant LIQUIDATION-THRESHOLD u125) ;; 125% collateralization ratio
(define-constant LIQUIDATION-PENALTY u110) ;; 10% penalty on liquidation
(define-constant COLLATERAL-RATIO u150) ;; 150% initial collateralization ratio
(define-constant MAX-LOAN-DURATION u2880) ;; ~20 days (144 blocks/day)
(define-constant MAX-INTEREST-RATE u1000) ;; 10% max interest rate

;; token definitions
;;
;; Data vars
(define-data-var minimum-collateral uint u100000) ;; in sats
(define-data-var protocol-fee uint u100) ;; basis points (1% = 100)
(define-data-var last-loan-id uint u0)

;; constants
;;
;; Data maps
(define-map loans
    { loan-id: uint }
    {
        borrower: principal,
        lender: principal,
        amount: uint,
        collateral: uint,
        interest-rate: uint,
        start-height: uint,
        end-height: uint,
        status: (string-ascii 20)
    }
)

;; data vars
;;
(define-map liquidations
    { loan-id: uint }
    {
        liquidator: principal,
        liquidation-height: uint,
        liquidation-amount: uint
    }
)

;; data maps
;;
(define-map user-loans
    principal
    (list 10 uint)
)




;; Read-only functions
(define-read-only (get-loan (loan-id uint))
    (map-get? loans { loan-id: loan-id })
)

(define-read-only (get-liquidation (loan-id uint))
    (map-get? liquidations { loan-id: loan-id })
)

(define-read-only (get-user-loans (user principal))
    (default-to (list) (map-get? user-loans user))
)





;;;;;;; Private functions;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Input validation functions
(define-private (is-valid-input 
    (amount uint) 
    (collateral uint) 
    (interest-rate uint) 
    (loan-duration uint)
)
    (and
        ;; Amount and collateral must be positive
        (> amount u0)
        (> collateral u0)

        ;; Interest rate within bounds
        (<= interest-rate MAX-INTEREST-RATE)

        ;; Loan duration within reasonable limits
        (and (> loan-duration u0) (<= loan-duration MAX-LOAN-DURATION))

        ;; Validate collateral ratio
        (is-collateral-ratio-valid amount collateral)
    )
)


;; Collateral and liquidation helper functions
(define-private (is-collateral-ratio-valid (loan-amount uint) (collateral-amount uint))
    (let
        (
            (min-collateral (* loan-amount COLLATERAL-RATIO))
        )
        (>= (* collateral-amount u10000) min-collateral)
    )
)

(define-private (calculate-current-collateral-ratio (loan-amount uint) (collateral-amount uint))
    (/ (* collateral-amount u10000) loan-amount)
)


;; Existing helper function
(define-private (calculate-max-withdrawable-collateral 
    (current-collateral uint) 
    (loan-amount uint)
)
    (let
        (
            (min-required (/ (* loan-amount COLLATERAL-RATIO) u10000))
            ;; Add a small buffer to prevent risky withdrawals
            (safe-buffer (/ min-required u10))
        )
        (if (> current-collateral (+ min-required safe-buffer))
            (- current-collateral (+ min-required safe-buffer))
            u0
        )
    )
)

;; Existing helper functions (calculate-interest, get-next-loan-id, etc.)
(define-private (calculate-interest (principal uint) (rate uint) (blocks uint))
    (let
        (
            (interest-per-block (/ (* principal rate) (* u10000 u144))) ;; Assuming 144 blocks per day
        )
        (* interest-per-block blocks)
    )
)

(define-private (get-next-loan-id)
    (let
        (
            (current-id (var-get last-loan-id))
            (next-id (+ current-id u1))
        )
        (var-set last-loan-id next-id)
        next-id
    )
)
