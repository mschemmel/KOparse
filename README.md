![GitHub](https://img.shields.io/github/license/mschemmel/KOparse)

# KOparse
A perl script to parse KOBAS 'annotate' output to tabular format.

[KOBAS](http://kobas.cbi.pku.edu.cn/kobas3) is a well known gene set enrichment tool,  offering the capability to annotate provided sequences or IDs as well as conduct enrichment analysis.
The annotation of transcripts or genes via homology comparison with for example _Arabidopsis thaliana_ is a valueable tool to gain amongst others GO terms or Pathway IDs of previously unavailable annotations.

However, the format of the results after annotation is not very convenient, as it is not structured as a table. Therefore it is necessary to parse the achieved results of the annotate tool for potential use in downstream analysis.

'annotate_parser' is a perl script parsing the results of the 'Annotate' section to tabular format.

## Usage
```
perl annotate_parser.pl -i inputfile -o outputfile
```

### Arguments
    -i /path/to/input_file
    -o /path/to/output_file
If no output path is specified, output is send to the console.

## Test
The 'test' folder contains a template file, generated with the 'annotate' tool from KOBAS using their provided test IDs. 
