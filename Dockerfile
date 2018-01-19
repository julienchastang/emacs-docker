FROM ubuntu:16.04

MAINTAINER Julien Chastang <chastang@ucar.edu>

###
# anaconda works better with bash
###

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

###
# House keeping
###

RUN apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade

###
# Install some Linux packages
###

RUN apt-get install -y curl git bzip2 sudo tar git gawk emacs install-info texinfo ispell aspell aspell-en hunspell hunspell-en-us ditaa texlive-xetex gnuplot texlive-bibtex-extra latexmk dvipng

###
# Set up emacs user account
###

RUN useradd -ms /bin/bash emacs

RUN adduser emacs sudo

RUN echo "emacs ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN echo 'emacs:docker' | chpasswd

ENV HOME /home/emacs

WORKDIR $HOME

###
# Create some directories
###

RUN mkdir -p $HOME/.emacs.d/git $HOME/work $HOME/downloads $HOME/bin

###
# Java
###

RUN apt-get install -y build-essential openjdk-8-jdk

# certificates / security

RUN dpkg --purge --force-depends ca-certificates-java

RUN apt-get install ca-certificates-java

ENV CURL_CA_BUNDLE /etc/ssl/certs/ca-certificates.crt

###
# Install miniconda
###

RUN mkdir -p $HOME/downloads

RUN cd $HOME/downloads && curl -SL \
  http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o \
  Miniconda3-latest-Linux-x86_64.sh

RUN /bin/bash $HOME/downloads/Miniconda3-latest-Linux-x86_64.sh -b -p \
  $HOME/anaconda/

ENV PATH $HOME/anaconda/bin:$PATH

RUN conda update --yes --quiet conda

ADD environment.yml $HOME/

RUN conda env update --name root -f $HOME/environment.yml

ADD pip.txt $HOME/

RUN pip install -r pip.txt

###
# Clone various repos
###

WORKDIR $HOME/.emacs.d/git

# emacs config
RUN  git clone -b python https://github.com/julienchastang/dotemacs

# org mode
RUN  git clone --branch release_9.1.6 https://code.orgmode.org/bzg/org-mode.git

# yasnippet'
RUN  git clone https://github.com/AndreaCrotti/yasnippet-snippets

# texinfo
RUN git clone https://github.com/julienchastang/texinfo /usr/share/info/jctexinfo

ADD dir-info $HOME/

RUN cat $HOME/dir-info >> /usr/share/info/dir

# Must manually curate some emacs packages not in melpa-stable

RUN git clone https://github.com/daic-h/emacs-rotate

RUN git clone https://github.com/novoid/title-capitalization.el

RUN git clone https://github.com/julienchastang/emacs-calfw

RUN git clone https://github.com/rlister/org-present

# build org mode
WORKDIR $HOME/.emacs.d/git/org-mode

RUN make autoloads

###
# Clojure
###

WORKDIR $HOME/bin

ENV PATH $HOME/bin:$PATH

RUN curl -SL \
    https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -o \
    $HOME/bin/lein

RUN sh $HOME/bin/lein

RUN chmod a+x $HOME/bin/lein

ADD profiles.clj $HOME/.lein/profiles.clj

###
# Emacs initialization
###

ADD init.el $HOME/.emacs.d/init.el

# kludge just to force emacs to run once to grab elpa
RUN emacs --batch -l $HOME/.emacs.d/init.el

RUN pip install -U $HOME/.emacs.d/elpa/jedi-core*

# Get rid of weird versions of org floating around
RUN rm -rf $HOME/.emacs.d/elpa/org-2*

###
# Work volumes
###

WORKDIR $HOME/work

VOLUME $HOME/work

###
# Wrapping up some stuff
###

RUN rm -rf $HOME/downloads/*

RUN chown -R emacs:emacs $HOME/

###
# Start container
###

USER emacs

ADD .bashrc $HOME/

CMD bash
