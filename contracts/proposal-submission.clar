;; Proposal Submission Contract
;; Records items for consideration in governance

;; Define admin
(define-data-var admin principal tx-sender)
(define-data-var proposal-count uint u0)

;; Map to store proposals
(define-map proposals
  uint
  {
    title: (string-ascii 100),
    proposer: principal,
    created-at: uint
  }
)

;; Map to track if a principal is allowed to submit proposals
(define-map allowed-proposers principal bool)

;; Public function to add an allowed proposer (admin only)
(define-public (add-proposer (proposer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (map-set allowed-proposers proposer true)
    (ok true)
  )
)

;; Public function to submit a proposal
(define-public (submit-proposal (title (string-ascii 100)))
  (let ((proposal-id (+ (var-get proposal-count) u1)))
    (asserts! (default-to false (map-get? allowed-proposers tx-sender)) (err u1))

    (map-set proposals proposal-id {
      title: title,
      proposer: tx-sender,
      created-at: block-height
    })

    (var-set proposal-count proposal-id)
    (ok proposal-id)
  )
)

;; Read-only function to get a proposal
(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

;; Read-only function to get the total number of proposals
(define-read-only (get-proposal-count)
  (var-get proposal-count)
)

;; Public function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (var-set admin new-admin)
    (ok true)
  )
)
