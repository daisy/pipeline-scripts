
        DAISY Pipeline 2 :: Braille Modules - 1.0 - September 6, 2012
===============================================================================


 1. About the Pipeline 2 Braille modules
 2. Contents of the package
 3. Installation
 4. Getting started
 5. Documentation
 6. Known limitations
 7. Contact


1. About the Pipeline 2 Braille modules
-------------------------------------------------------------------------------

The Braille modules for the DAISY Pipeline 2 provide support for the production
of PEF (Portable Embosser Format) from DAISY AI (NISO Z39.98-2012 - Authoring
and Interchange Framework for Adaptive XML Publishing) documents.

The modules have been primarily developed by Bert Frees at SBS (Swiss Library
for the Blind and Visually Impaired).



2. Content of the package
-------------------------------------------------------------------------------

The package includes an installer that will unpack the Braille modules in an
installation in the DAISY Pipeline 2 framework:

 - 'README.txt': this readme file.
 - 'braille-modules-{version}-install.jar': the installer



3. Installation
-------------------------------------------------------------------------------

The modules must be installed on top of the default distribution of the DAISY
Pipeline framework (version 1.3 or above), which can be downlaoded at:
  https://code.google.com/p/daisy-pipeline/downloads/list

The installer is an executable JAR file. Run it by double-clicking it or by
using the 'java -jar braille-modles-{version}.jar' command.

In the first step, you are asked to select the installation path. Choose the
same directory where you installed the DAISY Pipeline. You will get a warning:
"The directory already exists! Are you sure you want to install here and
possibly overwrite existing files?". Ignore this. In the next step you'll get
an overview of the packages that will be installed. Press "Next" a few times
and then "Done" to finish the installation.

See also:
  https://code.google.com/p/daisy-pipeline/wiki/ZedAIToPEFInstallation



4. Getting Started
-------------------------------------------------------------------------------

To run the zedai-to-pef conversion on the provided DAISY AI sample, run the
following command in your Pipeline 2 installation directory:

$ cli/dp2 zedai-to-pef \
        --i-source samples/zedai/alice.xml \
        --x-preview true \
        --x-output-dir ~/Desktop/out \
        --x-temp-dir /tmp

The output should be:

$ ls ~/Desktop/out
alice.pef.xml
alice.pef.html



5. Documentation
-------------------------------------------------------------------------------

See:
  https://code.google.com/p/daisy-pipeline/wiki/ZedAIToPEFUsage



6. Known limitations
-------------------------------------------------------------------------------

See:
  http://code.google.com/p/daisy-pipeline/wiki/BraillePrototypeFeatureSet
  
For bugs, please refer to the issue tracker:
 http://code.google.com/p/daisy-pipeline/issues/list



7. Contact 
-------------------------------------------------------------------------------

If you want to join the effort and contribute to the Pipeline 2 project, feel
free to join us on the developers discussion list hosted on Google Groups:
 http://groups.google.com/group/daisy-pipeline-dev

or contact the project lead (Romain Deltour) via email at
 `rdeltour (at) gmail (dot) com`
