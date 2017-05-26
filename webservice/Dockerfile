FROM debian:testing
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y install emacs24 python-seqdiag
ADD install.el /emacs/install.el
WORKDIR /emacs
ENV HOME /emacs
RUN emacs --batch --load install.el
ADD export.el /emacs/export.el
ADD ob-blockdiag.el /emacs/ob-blockdiag.el
ADD .blockdiagrc /emacs/.blockdiagrc
ADD LiberationSans-Regular.ttf /emacs/LiberationSans-Regular.ttf
ENV LANG en_US.UTF-8
