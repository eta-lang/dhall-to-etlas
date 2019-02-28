let Version = ./../types/Version.dhall

let id = λ(txt : Text) → txt

in λ(v : Version) → v Text id
