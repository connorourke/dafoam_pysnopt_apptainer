FROM dafoam/opt-packages:v3.1.2

USER dafoamuser
WORKDIR /home/dafoamuser

RUN . /home/dafoamuser/dafoam/loadDAFoam.sh && \
    mkdir -p "$DAFOAM_ROOT_PATH/repos" && \
    wget https://github.com/mdolab/pyoptsparse/archive/v2.9.1.tar.gz -O pyoptsparse.tar.gz && \
    tar -xzf pyoptsparse.tar.gz -C "$DAFOAM_ROOT_PATH/repos" && \
    rm pyoptsparse.tar.gz

RUN . /home/dafoamuser/dafoam/loadDAFoam.sh && \
    pip install "$DAFOAM_ROOT_PATH/repos/pyoptsparse-2.9.1"

RUN . /home/dafoamuser/dafoam/loadDAFoam.sh && \
    python - <<EOF
import pyoptsparse
print("pyoptsparse installed (SNOPT disabled)")
EOF
