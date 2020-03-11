with import <nixOld> {};

# Note, nix-channel == 19.03
# magma derivation doesn't find mkl libs properly on 19.09
# ...although magma can be built on 19.09 using openblas

let
  new = import <current> {};
  mag = pkgs.callPackage ./magma.nix{};
in

stdenv.mkDerivation rec {
  name = "env" ;
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = [ git hdf5 mkl mag cudatoolkit
    (python37.buildEnv.override {
      ignoreCollisions = true;
      extraLibs = with python37Packages; [
        (numpy.override { blas = mkl; })
        scipy  ## Currently doesn't use mkl =/
	pandas
	#scikitlearn ## Needs custom build
	#mkl-service
	pyproj
	gdal
	notebook
	cython
        matplotlib
	pip
	wheel
      ];
     })
    ];

  shellHook = ''
            alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' \pip"
            export PYTHONPATH="$(pwd)/_build/pip_packages/lib/python3.7/site-packages:$PYTHONPATH"
	    export CUDA_PATH=${pkgs.cudatoolkit}
	    export LD_LIBRARY_PATH="/run/opengl-driver:$CUDA_PATH/lib:${pkgs.cudatoolkit.lib}/lib:${mag}/lib"
	    export LDFLAGS="-L/lib -L$LD_LIBRARY_PATH"
            export MAGMA=${mag}
            unset SOURCE_DATE_EPOCH'';}

# Needs custom installs of cupy, scikit-cuda, and sklearn since the source
# for these packages is modified from upstream
