[pipeline-mod-braille][]
========================

Braille Production Modules for the [DAISY Pipeline 2][pipeline].

Project layout
--------------
Because of the very modular nature of DAISY Pipeline 2, browsing the
code is not always easy. In order to make it more obvious where to
find a particular piece of code, I've tried to organize the modules
into subdirectories in a logical and consistent way.

- [`pipeline-braille-scripts`](pipeline-braille-scripts) contains the
  two top-level *scripts* that are presented to the end-user, notably
  `zedai-to-pef` and `dtbook-to-pef`.

- [`pipeline-braille-utils`](pipeline-braille-utils) contains everything
  else: all the low-level building blocks that the scripts are made up
  from. The building blocks are divided into logical *groups* such as
  `css-utils`, `pef-utils`, `liblouis-utils`, etc.

See also
--------
 - [ZedAI to PEF script user guide](http://code.google.com/p/daisy-pipeline/wiki/ZedAIToPEFDoc)

Authors
-------
- [Bert Frees][bert]

License
-------
Copyright 2012-2014 [DAISY Consortium][daisy] 

This program is free software: you can redistribute it and/or modify
it under the terms of the [GNU Lesser General Public License][lgpl]
as published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Lesser General Public License for more details.


[pipeline-mod-braille]: https://github.com/daisy/pipeline-mod-braille
[pipeline]: http://code.google.com/p/daisy-pipeline
[bert]: http://github.com/bertfrees
[daisy]: http://www.daisy.org
[lgpl]: http://www.gnu.org/licenses/lgpl.html
