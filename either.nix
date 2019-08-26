{ mkDerivation, base, bifunctors, mtl, profunctors, QuickCheck
, semigroupoids, stdenv, test-framework, test-framework-quickcheck2
}:
mkDerivation {
  pname = "either";
  version = "5.0.1.1";
  sha256 = "0243d51d6a02ecb541e4854a588a9b6219a4690ebcbdb79387dd14ad519cdf27";
  libraryHaskellDepends = [
    base bifunctors mtl profunctors semigroupoids
  ];
  testHaskellDepends = [
    base QuickCheck test-framework test-framework-quickcheck2
  ];
  homepage = "http://github.com/ekmett/either/";
  description = "Combinators for working with sums";
  license = stdenv.lib.licenses.bsd3;
}
