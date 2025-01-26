;; Crop Management Contract

(define-data-var next-crop-id uint u0)

(define-map crops
  { crop-id: uint }
  {
    farmer: principal,
    crop-type: (string-ascii 50),
    planting-date: uint,
    expected-harvest-date: uint,
    field-location: (string-ascii 100),
    status: (string-ascii 20)
  }
)

(define-map crop-data
  { crop-id: uint }
  {
    soil-moisture: uint,
    temperature: uint,
    humidity: uint,
    last-updated: uint
  }
)

(define-public (register-crop (crop-type (string-ascii 50)) (planting-date uint) (expected-harvest-date uint) (field-location (string-ascii 100)))
  (let
    ((new-id (var-get next-crop-id))
     (farmer tx-sender))
    (map-set crops
      { crop-id: new-id }
      {
        farmer: farmer,
        crop-type: crop-type,
        planting-date: planting-date,
        expected-harvest-date: expected-harvest-date,
        field-location: field-location,
        status: "active"
      }
    )
    (var-set next-crop-id (+ new-id u1))
    (ok new-id)
  )
)

(define-public (update-crop-data (crop-id uint) (soil-moisture uint) (temperature uint) (humidity uint))
  (let
    ((farmer tx-sender))
    (match (map-get? crops { crop-id: crop-id })
      crop (begin
        (asserts! (is-eq farmer (get farmer crop)) (err u403))
        (map-set crop-data
          { crop-id: crop-id }
          {
            soil-moisture: soil-moisture,
            temperature: temperature,
            humidity: humidity,
            last-updated: block-height
          }
        )
        (ok true)
      )
      (err u404)
    )
  )
)

(define-public (update-crop-status (crop-id uint) (new-status (string-ascii 20)))
  (let
    ((farmer tx-sender))
    (match (map-get? crops { crop-id: crop-id })
      crop (begin
        (asserts! (is-eq farmer (get farmer crop)) (err u403))
        (map-set crops
          { crop-id: crop-id }
          (merge crop { status: new-status })
        )
        (ok true)
      )
      (err u404)
    )
  )
)

(define-read-only (get-crop (crop-id uint))
  (map-get? crops { crop-id: crop-id })
)

(define-read-only (get-crop-data (crop-id uint))
  (map-get? crop-data { crop-id: crop-id })
)

