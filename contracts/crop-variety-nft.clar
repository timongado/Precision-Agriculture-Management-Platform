;; Crop Variety NFT Contract

(define-non-fungible-token crop-variety uint)

(define-data-var last-token-id uint u0)

(define-map token-metadata
  { token-id: uint }
  {
    variety-name: (string-utf8 100),
    developer: principal,
    characteristics: (string-utf8 500),
    registration-date: uint
  }
)

(define-public (mint-crop-variety (variety-name (string-utf8 100)) (characteristics (string-utf8 500)))
  (let
    ((new-token-id (+ (var-get last-token-id) u1))
     (developer tx-sender))
    (try! (nft-mint? crop-variety new-token-id developer))
    (map-set token-metadata
      { token-id: new-token-id }
      {
        variety-name: variety-name,
        developer: developer,
        characteristics: characteristics,
        registration-date: block-height
      }
    )
    (var-set last-token-id new-token-id)
    (ok new-token-id)
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))
    (nft-transfer? crop-variety token-id sender recipient)
  )
)

(define-read-only (get-token-metadata (token-id uint))
  (map-get? token-metadata { token-id: token-id })
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? crop-variety token-id))
)

