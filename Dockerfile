###
# for Python related development
###

FROM unidata/python

MAINTAINER Julien Chastang <chastang@ucar.edu>

###
# Usual maintenance
###

USER root

# temporarily remove conda b/c conda causes problems with apt-get 
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get update

RUN apt-get install -y tar curl git gawk emacs install-info texinfo

###
# various emacs ancillary programs
###

RUN apt-get install -y ispell aspell aspell-en hunspell hunspell-en-us ditaa texlive-xetex gnuplot texlive-bibtex-extra latexmk dvipng

WORKDIR $HOME

###
# Create some directories
###

RUN mkdir -p $HOME/.emacs.d/git

RUN mkdir -p $HOME/work

RUN mkdir -p $HOME/downloads

RUN mkdir -p $HOME/bin

###
# Java
###

RUN apt-get install -y build-essential openjdk-8-jdk

# certificates / security

RUN dpkg --purge --force-depends ca-certificates-java

RUN apt-get install ca-certificates-java

ENV CURL_CA_BUNDLE /etc/ssl/certs/ca-certificates.crt

###
# conda 
###

USER python

# reinsert conda to path
ENV PATH $HOME/anaconda/bin:$PATH

ADD emacs-python.yml $HOME/

# Should work but doesn't
# RUN conda env update --name root -f $HOME/emacs-python.yml

RUN conda config --add channels conda-forge && \
    conda install -y -n root jedi rope flake8 pylint pip jupyter_client ipykernel jupyter_console sphinx && \
    conda update -y --all

RUN pip install epc importmagic autopep8 yapf

WORKDIR $HOME/.emacs.d/git

###
# Clone various repos
###

USER root

# emacs config
RUN  git clone -b python https://github.com/julienchastang/dotemacs

# org mode
RUN  git clone --branch release_8.3.6 git://orgmode.org/org-mode.git

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

USER root

RUN rm -rf $HOME/downloads/*

ADD .bashrc $HOME/

RUN chown -R python:python $HOME/

###
# Start container
###

USER python

CMD bash
