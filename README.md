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
cd test-python
```

```bash
poetry run pytest tests/test_add.p
```

```bash
poetry run pytest tests/test_matrix_mul.py
```

> 💡 Note:

We use Python to generate the test cases and use relevant parameter(like EC points in Solidity test suites)

### Format

```bash
$ forge fmt
```