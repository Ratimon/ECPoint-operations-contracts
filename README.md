## ECPoint-operations-contracts


Elliptic curve point operations on solidity contract that leverages the precompiles : **add** and **multiplication** for Elliptic curve point (EIP196)

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