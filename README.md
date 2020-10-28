
#Hash

Repository for Locality Sensitive Hash. 

## Getting Start

This repository contains the code for experiments in the following papers.

> Yeqing Li, Chen Chen, Wei Liu, and Junzhou Huang, "Sub-Selective Quantization for Large-Scale Image Search", AAAI Conference on Artificial Intelligence (AAAI), 2014. \

> Yeqing Li, Wei Liu, and Junzhou Huang, “Sub-Selective Quantization for Learning Binary Code in Large-Scale Image Search”, IEEE Transactions on Pattern Analysis and Machine Intelligence (TPAMI), 2017.

Change directory to data and use the get_data.sh to download the data.

```bash
cd data
sh get_data.sh
```

Use following scripts to run the experiments.
- Main_MNIST.m reproduces the results on MNIST dataset.
- Main_CIFAR.m reproduces the results on CIFAR dataset.
- Main_TINY1M.m reproduces the results on Tiny1M dataset (weakly label).

The "Main_Show.m" is used to display the stored results.

### Datasets

- MNIST (mnist_split.mat)
- CIFAR (cifar_split.m)
- Tiny1M (eightyMsubset_hash_final.mat, eightyMsubset_gnd.mat)

##Bibtex

	@inproceedings{li2014subselective,
	  title={Subselective quantization for large-scale image search},
	  author={Li, Yeqing and Chen, Chen and Liu, Wei and Huang, Junzhou},
	  booktitle={Proc. AAAI Conference on Artificial Intelligence (AAAI)},
	  year={2014}
	}

