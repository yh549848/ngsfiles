#! /bin/env python
#
# Strip attributes from sequence name
#
# Usage:
#   this.py <fasta>
#

import sys


def main():
    fasta = sys.argv[1]
    with open(fasta) as f:
        for l in f:
            if l.startswith('>'):
                print(l.split('|')[0].split(' ')[0])
            else:
                print(l, end='')


if __name__ == '__main__':
    main()
