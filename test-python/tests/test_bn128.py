from py_ecc.bn128 import curve_order, G1, multiply, add, eq, neg


def test_simple_add():

    print(G1)
    print(add(G1, G1))

    five_over_two = (5 * pow(2, -1, curve_order)) % curve_order
    one_half = pow(2, -1, curve_order)
    g_three = add(multiply(G1, five_over_two), multiply(G1, one_half))

    print("five_over_two is {}".format(five_over_two))
    print("one_half is {}".format(one_half))
    print("LHS is {}".format(g_three))
    print("RHS is {}".format(multiply(G1, 3)))

    assert False

def test_zk_add_int():

    # Prover
    secret_x = 5
    secret_y = 10

    # 15 = 5 + 10
    public = secret_x + secret_y

    e_x = multiply(G1, secret_x)
    e_y = multiply(G1, secret_y)

    proof = (e_x, e_y, public)

    # verifier
    assert multiply(G1, proof[2]) == add(proof[0], proof[1])

def test_zk_add_rational():

    # Prover
    numerator1 = 53
    denominator1 = 192
    numerator2 = 61
    denominator2 = 511

    #  53/192 + 61/511 = 38795/98112
    #  53 * inv(192) + 61 * inv(511) = 38795 * inv(98112)

    #  G * (53/192) + G * (61/511) = G * (38795/98112)

   

    num_over_den1 = (numerator1 * pow(denominator1, -1, curve_order)) % curve_order
    e_x = multiply(G1, num_over_den1)

    num_over_den2 = (numerator2 * pow(denominator2, -1, curve_order)) % curve_order
    e_y = multiply(G1, num_over_den2)

    numerator3 = 38795
    denominator3 = 98112

    # public = 38795 * pow(98112, -1, curve_order)
    num_over_den3 = (numerator3 * pow(denominator3, -1, curve_order)) % curve_order
    e_public = multiply(G1, num_over_den3)

    print("e_x {}".format(e_x))
    print("e_y {}".format(e_y))
    print("LHS {}".format(add( e_x, e_y )))
    print("RHS {}".format(e_public))

    assert False