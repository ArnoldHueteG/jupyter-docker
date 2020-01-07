FROM jupyter/scipy-notebook
USER root
COPY .aws/* .aws/
RUN conda install s3fs && \
    conda install fastparquet && \
    conda install -c conda-forge awscli
USER jovyan
