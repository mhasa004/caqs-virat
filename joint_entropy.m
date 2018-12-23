function J = joint_entropy(P)

J = -sum(sum(P.*log2(P+1e-6)));