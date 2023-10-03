import numpy as np
from py_ecc.bn128 import curve_order, G1, multiply, add, eq, neg


def matrix_multiply(A, B):
    A = np.array(A)
    B = np.array(B)

    C = A @ B 
    # Alternatively, use np.dot(A, B)
    return C

def test_simple_matrix_multiply():
    # 2x + 8y = 7944
    # 5x + 3y = 4764

    # Known solution (known only to the prover)
    # x = 420
    # y = 888

    A = [[2, 8],[5, 3]]
    B = [[420],[888]]

    C = [[7944],[4764]]

    matrix_result = matrix_multiply(A, B)
    print(matrix_result)

    assert np.all(matrix_result == C)

def test_zk_matrix_multiply():
    # 2x + 8y = 7944
    # 5x + 3y = 4764

    # Known solution (known only to the prover)
    # x = 420
    # y = 888

    # Prover
    secret_x = 420
    secret_y = 888

    # encrypted x
    e_x = multiply(G1, secret_x)
    # encrypted y
    e_y = multiply(G1, secret_y)

    print("encrypted x: e_x {}".format(e_x))
    print("encrypted y: e_y {}".format(e_y))

    # 7944 = 2 * 420 +  8 * 888
    public1 = 2*secret_x + 8*secret_y
    # print("public1 {}".format(public1))

    two_e_x = multiply(e_x, 2)
    eight_e_y = multiply(e_y, 8)
    e_public1 = multiply(G1, public1)

    # print("two_e_x {}".format(two_e_x))
    # print("eight_e_y {}".format(eight_e_y))

    # print("e_2x + e_8y: LHS1 {}".format(add( two_e_x, eight_e_y )))
    print("encrypted public 1: RHS1 {}".format(e_public1))


    # 4764 = 5x + 3y 
    public2 = 5*secret_x + 3*secret_y
    # print("public2 {}".format(public2))

    five_e_x = multiply(e_x, 5)
    three_e_y = multiply(e_y, 3)
    e_public2 = multiply(G1, public2)

    # print("five_e_x {}".format(five_e_x))
    # print("three_e_y {}".format(three_e_y))

    # print("e_5x + e_3y: LHS2 {}".format(add( five_e_x, three_e_y )))
    print("encrypted public 2: RHS2 {}".format(e_public2))

    # verifier
    assert add( two_e_x, eight_e_y ) == e_public1
    assert add( five_e_x, three_e_y ) == e_public2
    assert False