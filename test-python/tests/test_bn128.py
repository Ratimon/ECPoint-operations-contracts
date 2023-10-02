from py_ecc.bn128 import G1, multiply, add, eq, neg


def test_add():

    print(G1)

    print(add(G1, G1))
    assert False