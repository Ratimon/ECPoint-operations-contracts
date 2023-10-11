from py_ecc.bn128 import G1, G2, multiply, neg, pairing



def test_zk_verify():


    A = multiply(G2, 5)
    B = multiply(G1, 6)
    C = multiply(G1, 5 * 6)

    print("G1  {}".format(G1 ))

    print("pairing(A, B) == pairing(G2, C)  {}".format(pairing(A, B) == pairing(G2, C) ))

    # 0 = − A B + α β + X γ + C δ

    # where X = 2 x G1 + 3 x G1 + 5 x G1
    
    # 3 * 27 = 2 * 10 + 7 * 3 + (2 + 3 + 5) * 2 + 4 * 5
    # 0 = - 61 * 1 + 7 * 3 + (2 + 3 + 5) * 2 + 4 * 5

    # A1 = 61
    # A2 = 1

    # B1 = 7
    # B2 = 3

    # C1 = 10
    # C2 = 2

    # D1 = 4
    # D2 = 5

    A1 = multiply(G1, 61)
    A2 = multiply(G2, 1)
    A1_negate = neg(A1)

    B1 = multiply(G1, 7)
    B2 = multiply(G2, 3)

    C1 = multiply(G1, 10)
    C2 = multiply(G2, 2)

    D1 = multiply(G1, 4)
    D2 = multiply(G2, 5)

    print("e_A1 {}".format(A1))
    print("e_A1_negate {}".format(A1_negate))
    print("e_A2 or B2 {}".format(A2))
    
    print("e_B1 or α1 {}".format(B1))
    print("e_B2 or β2 {}".format(B2))

    print("e_C1 {}".format(C1))
    print("e_C2 or γ2 {}".format(C2))

    print("e_D1 or C1 {}".format(D1))
    print("e_D2 or δ2 {}".format(D2))

    assert False