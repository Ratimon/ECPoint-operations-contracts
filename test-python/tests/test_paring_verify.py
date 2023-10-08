from py_ecc.bn128 import curve_order, G1, G2, multiply, add, eq, neg, pairing



def test_zk_verify():


    # A = multiply(G2, 5)
    # B = multiply(G1, 6)
    # C = multiply(G1, 5 * 6)

    # print("pairing(A, B) == pairing(G2, C)  {}".format(pairing(A, B) == pairing(G2, C) ))
    
    # 3 * 27 = 2 * 10 + 7 * 3 + (2 + 3 + 5) * 2 + 4 * 5
    # 0 = - 61 * 1 + 7 * 3 + (2 + 3 + 5) * 2 + 4 * 5

    # a = - 61
    # b = 1

    # c = 7
    # d = 3

    # e = 10
    # f = 2

    # g = 4
    # h = 5

    A = multiply(G1, 61)
    B = multiply(G2, 1)
    A_negate = neg(A)

    C = multiply(G1, 7)
    D = multiply(G2, 3)

    E = multiply(G1, 10)
    F = multiply(G2, 2)

    G = multiply(G1, 4)
    H = multiply(G2, 5)

    print("e_A_negate {}".format(A_negate))
    print("e_B {}".format(B))
    

    print("e_C {}".format(C))
    print("e_D {}".format(D))

    print("e_E {}".format(E))
    print("e_F {}".format(F))

    print("e_G {}".format(G))
    print("e_H {}".format(H))

    assert False