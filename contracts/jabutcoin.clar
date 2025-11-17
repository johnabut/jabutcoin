;; Jabutcoin fungible token smart contract

(define-data-var contract-owner principal tx-sender)
(define-data-var total-supply uint u0)

(define-map balances
  ((account principal))
  ((balance uint)))

(define-constant token-name "Jabutcoin")
(define-constant token-symbol "JAB")
(define-constant token-decimals u6)

;; Errors
(define-constant err-not-authorized (err u100))
(define-constant err-insufficient-balance (err u101))

;; Read-only helpers
(define-read-only (get-name)
  (ok token-name))

(define-read-only (get-symbol)
  (ok token-symbol))

(define-read-only (get-decimals)
  (ok token-decimals))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-balance (owner principal))
  (ok (default-to u0 (get balance (map-get? balances { account: owner })))))

(define-read-only (get-owner)
  (ok (var-get contract-owner)))

;; Internal transfer helper
(define-private (internal-transfer (amount uint) (sender principal) (recipient principal))
  (let ((sender-balance (default-to u0 (get balance (map-get? balances { account: sender }))))
       (recipient-balance (default-to u0 (get balance (map-get? balances { account: recipient })))))
    (begin
      (asserts! (>= sender-balance amount) err-insufficient-balance)
      (map-set balances { account: sender } { balance: (- sender-balance amount) })
      (map-set balances { account: recipient } { balance: (+ recipient-balance amount) })
      (ok true))))

;; Public functions

;; Transfer tokens from sender to recipient.
;; Sender must match tx-sender.
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq sender tx-sender) err-not-authorized)
    (try! (internal-transfer amount sender recipient))
    (ok true)))

;; Mint new tokens to a recipient. Only the contract owner may mint.
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorized)
    (let ((current-balance (default-to u0 (get balance (map-get? balances { account: recipient }))))
          (current-supply (var-get total-supply)))
      (begin
        (var-set total-supply (+ current-supply amount))
        (map-set balances { account: recipient } { balance: (+ current-balance amount) })
        (ok true)))))

;; Burn tokens from the caller's balance.
(define-public (burn (amount uint))
  (let ((caller tx-sender)
        (caller-balance (default-to u0 (get balance (map-get? balances { account: tx-sender }))))
        (current-supply (var-get total-supply)))
    (begin
      (asserts! (>= caller-balance amount) err-insufficient-balance)
      (map-set balances { account: caller } { balance: (- caller-balance amount) })
      (var-set total-supply (- current-supply amount))
      (ok true))))
