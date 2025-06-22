;; Collaboration Manager Verification Contract
;; Validates and manages collaboration managers

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_MANAGER (err u101))
(define-constant ERR_NOT_MANAGER (err u102))

;; Data maps
(define-map collaboration-managers principal bool)
(define-map manager-details principal {
    name: (string-ascii 50),
    team-id: uint,
    verified-at: uint
})

;; Read-only functions
(define-read-only (is-collaboration-manager (manager principal))
    (default-to false (map-get? collaboration-managers manager))
)

(define-read-only (get-manager-details (manager principal))
    (map-get? manager-details manager)
)

;; Public functions
(define-public (register-manager (name (string-ascii 50)) (team-id uint))
    (let ((caller tx-sender))
        (asserts! (not (is-collaboration-manager caller)) ERR_ALREADY_MANAGER)
        (map-set collaboration-managers caller true)
        (map-set manager-details caller {
            name: name,
            team-id: team-id,
            verified-at: block-height
        })
        (ok true)
    )
)

(define-public (revoke-manager (manager principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-collaboration-manager manager) ERR_NOT_MANAGER)
        (map-delete collaboration-managers manager)
        (map-delete manager-details manager)
        (ok true)
    )
)
