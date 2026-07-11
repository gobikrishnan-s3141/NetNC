# Updates made to NetNC

## mincut - *itercut.py*
- Syntax update : Python 2--> 3
    - print()
    - , err --> as err
- networkx
    - https://networkx.org/documentation/networkx-2.1/reference/algorithms/generated/networkx.algorithms.components.connected_component_subgraphs.html
    - Stoer-Wagner algorithm:
        - https://research.google/blog/solving-the-minimum-cut-problem-for-undirected-graphs/
- *install.sh* script
- C standard library issue --> fixed by using GCC version 13 as it still uses K&R style emply () parameters for any arguments
- Before vs after optimisation (Stoer-Wagner algorithm)
```bash
time python mincut/itercut.py -i test/output/NNConly/NNCz10.FDRthresholded_pairs.txt -o test/output/mincutOnly/NNCz10_FDR0pt1_mincutThresh0pt1.txt -t 0.1

real    3m10.127s
user    3m10.064s
sys     0m0.060s
```

```bash
time python mincut/itercut.py -i test/output/NNConly/NNCz10.FDRthresholded_pairs.txt -o test/output/mincutOnly/NNCz10_FDR0pt1_mincutThresh0pt1.txt -t 0.1

real	0m0.815s
user	0m0.711s
sys	0m0.104s
```
