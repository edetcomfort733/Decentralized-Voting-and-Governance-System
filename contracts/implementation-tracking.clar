;; Implementation Tracking Contract
;; Monitors execution of approved measures

;; Define admin
(define-data-var admin principal tx-sender)

;; Map to track implementation status
(define-map implementation-status
  uint
  {
    proposal-id: uint,
    completed: bool,
    implementer: principal,
    start-time: uint,
    completion-time: uint
  }
)

;; Map to track approved proposals
(define-map approved-proposals uint bool)

;; Public function to mark a proposal as approved (admin only)
(define-public (mark-proposal-approved (proposal-id uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (map-set approved-proposals proposal-id true)
    (ok true)
  )
)

;; Public function to initialize implementation tracking (admin only)
(define-public (initialize-implementation (proposal-id uint) (implementer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (asserts! (default-to false (map-get? approved-proposals proposal-id)) (err u2))

    (map-set implementation-status proposal-id {
      proposal-id: proposal-id,
      completed: false,
      implementer: implementer,
      start-time: block-height,
      completion-time: u0
    })

    (ok true)
  )
)

;; Public function to mark implementation as completed (admin or implementer)
(define-public (complete-implementation (proposal-id uint))
  (let (
    (current-status (default-to
      {
        proposal-id: u0,
        completed: false,
        implementer: tx-sender,
        start-time: u0,
        completion-time: u0
      }
      (map-get? implementation-status proposal-id)))
  )
    (asserts! (or (is-eq tx-sender (var-get admin)) (is-eq tx-sender (get implementer current-status))) (err u1))
    (asserts! (is-some (map-get? implementation-status proposal-id)) (err u2))

    (map-set implementation-status
      proposal-id
      (merge current-status {
        completed: true,
        completion-time: block-height
      })
    )

    (ok true)
  )
)

;; Read-only function to get implementation status
(define-read-only (get-implementation-status (proposal-id uint))
  (map-get? implementation-status proposal-id)
)

;; Public function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (var-set admin new-admin)
    (ok true)
  )
)
