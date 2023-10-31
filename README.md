## ECPoint-operations-contracts


Elliptic curve point operations on solidity contract that:

- leverages the pre-compiles : **add** and **multiplication** (EIP196) **paring** (EIP197) for Elliptic curve point

- **Encrypted R1CS verifier** in the form : $`\
L\mathbf{\vec{[s]_1}}\odot R\mathbf{\vec{[s]_2}} = O\mathbf{\vec{[s]}_{12}}`$


## Usage

### Build

```bash
forge build
```

### Test

#### Test Suites on Solidity Implementation

```bash
forge test -vvvv
```

#### Test Suites on Python Poc

```bash
poetry run pytest tests-python/test_add.py
```

```bash
poetry run pytest tests-python/test_matrix_mul.py
```

```bash
poetry run pytest tests-python/test_simple_verify.py
```

```bash
poetry run pytest tests-python/test_r1cs_verifier.py
```

> 💡 Note:

We use Python to generate the test cases and use relevant parameters(like EC points in Solidity test suites)

### Format

```bash
$ forge fmt
```