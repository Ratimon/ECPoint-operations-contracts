import numpy as np


def matrix_multiply(A, B):
    A = np.array(A)
    B = np.array(B)

    C = A @ B 
    # Alternatively, use np.dot(A, B)

    return C

def test_simple_matrix_multiply():
    A = [[1,2,3],[4,5,6],[7,8,9]]
    B = [[1,1,1],[2,2,2],[3,3,3]]

    matrix_result = matrix_multiply(A, B)
    print(matrix_result)
    assert False

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
