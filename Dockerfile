FROM jvans/maven_weekly

RUN git clone https://github.com/jvans1/maven_weekly.git
RUN cabal update 
RUN cabal install /maven_weekly/mavenweekly.cabal

ENTRYPOINT /maven_weekly/dist/build/maven_weekly/maven_weekly

EXPOSE  5000
