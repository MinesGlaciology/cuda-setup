with import <nixOld> {};

let
  new = import <unstable> {};
in

stdenv.mkDerivation rec {
  name = "env" ;
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = [ git hdf5 mkl new.magma cudatoolkit
    (python36.buildEnv.override {
      ignoreCollisions = true;
      extraLibs = with python36Packages; [
        numpy
	pandas
	scikitlearn
	#mkl-service
	pyproj
	gdal
	notebook
	cython
        scipy
        matplotlib
	pip
	wheel
      ];
     })
    ];

  shellHook = ''
            alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' \pip"
            export PYTHONPATH="$(pwd)/_build/pip_packages/lib/python3.6/site-packages:$PYTHONPATH"
	    export CUDA_PATH=${pkgs.cudatoolkit}
	    export LD_LIBRARY_PATH="/run/opengl-driver"
	    export LDFLAGS="-L/lib -L$LD_LIBRARY_PATH"
            unset SOURCE_DATE_EPOCH'';}

