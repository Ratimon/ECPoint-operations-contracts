from py_ecc.bn128 import curve_order, G1, G2, multiply, add, eq, neg, pairing



def test_zk_verify():


    # A = multiply(G2, 5)
    # B = multiply(G1, 6)
    # C = multiply(G1, 5 * 6)

    # # pairing(A, B) == pairing(G2, C) 

    # print("pairing(A, B) == pairing(G2, C)  {}".format(pairing(A, B) == pairing(G2, C) ))


    print("G1 {}".format(G1))
    print("neg(G1) {}".format(neg(G1)))


    
    # 3 * 27 = 2 * 10 + 7 * 3 + (2 + 3 + 5) * 2 + 4 * 5
    # 0 = - 61 * 1 + 7 * 3 + (2 + 3 + 5) * 2 + 4 * 5

    # a = 61
    # b = 1

    # c = 7
    # d = 3

    # e = 10
    # f = 2

    # g = 4
    # h = 5

    A = multiply(G2, 61)
    B = multiply(G1, 1)

    C = multiply(G2, 7)
    D = multiply(G1, 3)

    E = multiply(G2, 10)
    F = multiply(G1, 2)

    G = multiply(G2, 4)
    H = multiply(G1, 5)

    LHS = pairing(A, B)


    print("LHS {}".format(LHS))
    # print("pairing(A, B) == pairing(C, G1) {}".format(pairing(A, B) == pairing(C, D)))

    # RHS1 = pairing(C, D)
    # RHS2 = pairing(E, F)
    # RHS3 = pairing(G, H)

    # RHS = add(add(RHS1, RHS2), RHS3)


    
    # print("RHS {}".format(RHS))

    assert False