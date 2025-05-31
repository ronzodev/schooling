class MathFormula {
  final String name;
  final String? latex;
  final String description;
  final String? example;

  MathFormula({
    required this.name,
    this.latex,
    required this.description,
    this.example,
  });
}

// Sample formulas data
final List<MathFormula> algebraFormulas = [
  // Previous formulas
  MathFormula(
    name: 'Quadratic Formula',
    latex: r'x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}',
    description: 'Used to find the roots of a quadratic equation ax² + bx + c = 0',
    example: 'For x² - 5x + 6 = 0, solutions are x=2 and x=3',
  ),
  MathFormula(
    name: 'Binomial Theorem',
    latex: r'(a + b)^n = \sum_{k=0}^{n} \binom{n}{k} a^{n-k}b^k',
    description: 'Expands the power of a binomial expression',
  ),

  // Polynomial Formulas
  MathFormula(
    name: 'Factor Theorem',
    latex: r'If \ P(a) = 0, \ then \ (x - a) \ is \ a \ factor \ of \ P(x)',
    description: 'Determines factors of polynomials',
  ),
  MathFormula(
    name: 'Remainder Theorem',
    latex: r'P(a) \ is \ the \ remainder \ when \ P(x) \ is \ divided \ by \ (x - a)',
    description: 'Finds remainder without polynomial division',
  ),
  MathFormula(
    name: 'Sum of Roots (Quadratic)',
    latex: r'\alpha + \beta = -\frac{b}{a}',
    description: 'For ax² + bx + c = 0',
  ),
  MathFormula(
    name: 'Product of Roots (Quadratic)',
    latex: r'\alpha \beta = \frac{c}{a}',
    description: 'For ax² + bx + c = 0',
  ),
  MathFormula(
    name: 'Cubic Formula (Vieta)',
    latex: r'For \ ax^3 + bx^2 + cx + d = 0: \ \alpha+\beta+\gamma=-\frac{b}{a}, \ \alpha\beta+\alpha\gamma+\beta\gamma=\frac{c}{a}, \ \alpha\beta\gamma=-\frac{d}{a}',
    description: 'Relations between roots and coefficients',
  ),

  // Exponents and Logarithms
  MathFormula(
    name: 'Exponent Product Rule',
    latex: r'a^m \times a^n = a^{m+n}',
    description: 'When multiplying same bases, add exponents',
  ),
  MathFormula(
    name: 'Exponent Quotient Rule',
    latex: r'\frac{a^m}{a^n} = a^{m-n}',
    description: 'When dividing same bases, subtract exponents',
  ),
  MathFormula(
    name: 'Power of Power',
    latex: r'(a^m)^n = a^{mn}',
    description: 'When raising a power to another power, multiply exponents',
  ),
  MathFormula(
    name: 'Negative Exponent',
    latex: r'a^{-n} = \frac{1}{a^n}',
    description: 'Negative exponents represent reciprocals',
  ),
  MathFormula(
    name: 'Fractional Exponent',
    latex: r'a^{1/n} = \sqrt[n]{a}',
    description: 'Roots can be written as fractional exponents',
  ),
  MathFormula(
    name: 'Logarithm Definition',
    latex: r'\log_b a = c \ \Leftrightarrow \ b^c = a',
    description: 'Logarithm is the inverse of exponentiation',
  ),
  MathFormula(
    name: 'Logarithm Product Rule',
    latex: r'\log_b (xy) = \log_b x + \log_b y',
    description: 'Log of product is sum of logs',
  ),
  MathFormula(
    name: 'Logarithm Quotient Rule',
    latex: r'\log_b \left(\frac{x}{y}\right) = \log_b x - \log_b y',
    description: 'Log of quotient is difference of logs',
  ),
  MathFormula(
    name: 'Logarithm Power Rule',
    latex: r'\log_b (x^n) = n \log_b x',
    description: 'Log of power is exponent times log',
  ),
  MathFormula(
    name: 'Change of Base Formula',
    latex: r'\log_b a = \frac{\log_k a}{\log_k b}',
    description: 'Allows conversion between logarithm bases',
  ),

  // Sequences and Series
  MathFormula(
    name: 'Arithmetic Sequence nth Term',
    latex: r'a_n = a_1 + (n-1)d',
    description: 'Where d is the common difference',
  ),
  MathFormula(
    name: 'Arithmetic Series Sum',
    latex: r'S_n = \frac{n}{2}(a_1 + a_n) \ or \ S_n = \frac{n}{2}[2a_1 + (n-1)d]',
    description: 'Sum of first n terms of arithmetic sequence',
  ),
  MathFormula(
    name: 'Geometric Sequence nth Term',
    latex: r'a_n = a_1 \times r^{n-1}',
    description: 'Where r is the common ratio',
  ),
  MathFormula(
    name: 'Finite Geometric Series Sum',
    latex: r'S_n = a_1 \frac{1 - r^n}{1 - r} \ (r \neq 1)',
    description: 'Sum of first n terms of geometric sequence',
  ),
  MathFormula(
    name: 'Infinite Geometric Series Sum',
    latex: r'S = \frac{a_1}{1 - r} \ (|r| < 1)',
    description: 'Sum of infinite converging geometric series',
  ),

  // Factorials and Combinations
  MathFormula(
    name: 'Factorial Definition',
    latex: r'n! = n \times (n-1) \times \cdots \times 1',
    description: 'Product of all positive integers up to n',
  ),
  MathFormula(
    name: 'Permutations',
    latex: r'P(n, k) = \frac{n!}{(n-k)!}',
    description: 'Arrangements of k items from n',
  ),
  MathFormula(
    name: 'Combinations',
    latex: r'C(n, k) = \binom{n}{k} = \frac{n!}{k!(n-k)!}',
    description: 'Selections of k items from n',
  ),
  MathFormula(
    name: 'Binomial Coefficient Identity',
    latex: r'\binom{n}{k} = \binom{n}{n-k}',
    description: 'Symmetry property of combinations',
  ),
  MathFormula(
    name: 'Pascal\'s Identity',
    latex: r'\binom{n+1}{k} = \binom{n}{k} + \binom{n}{k-1}',
    description: 'Recursive relation in Pascal\'s Triangle',
  ),

  // Inequalities
  MathFormula(
    name: 'Triangle Inequality',
    latex: r'|a + b| \leq |a| + |b|',
    description: 'Absolute value inequality',
  ),
  MathFormula(
    name: 'AM-GM Inequality',
    latex: r'\frac{a + b}{2} \geq \sqrt{ab} \ (a, b \geq 0)',
    description: 'Arithmetic mean ≥ Geometric mean',
  ),
  MathFormula(
    name: 'Cauchy-Schwarz Inequality',
    latex: r'\left(\sum a_i b_i\right)^2 \leq \left(\sum a_i^2\right) \left(\sum b_i^2\right)',
    description: 'Fundamental inequality in vector spaces',
  ),
  MathFormula(
    name: 'Bernoulli\'s Inequality',
    latex: r'(1 + x)^n \geq 1 + nx \ (x > -1, n \in \mathbb{N})',
    description: 'Approximation for exponents',
  ),

  // Complex Numbers
  MathFormula(
    name: 'Imaginary Unit',
    latex: r'i = \sqrt{-1}, \ i^2 = -1',
    description: 'Definition of imaginary number',
  ),
  MathFormula(
    name: 'Complex Number Form',
    latex: r'z = a + bi',
    description: 'Rectangular form of complex number',
  ),
  MathFormula(
    name: 'Complex Conjugate',
    latex: r'\overline{a + bi} = a - bi',
    description: 'Reflection over real axis',
  ),
  MathFormula(
    name: 'Modulus of Complex Number',
    latex: r'|z| = \sqrt{a^2 + b^2}',
    description: 'Distance from origin in complex plane',
  ),
  MathFormula(
    name: 'Euler\'s Formula',
    latex: r'e^{i\theta} = \cos \theta + i \sin \theta',
    description: 'Relationship between exponential and trigonometric functions',
  ),
  MathFormula(
    name: 'De Moivre\'s Theorem',
    latex: r'(\cos \theta + i \sin \theta)^n = \cos (n\theta) + i \sin (n\theta)',
    description: 'Powers of complex numbers',
  ),

  // Additional Polynomial Formulas
  MathFormula(
    name: 'Difference of Squares',
    latex: r'a^2 - b^2 = (a - b)(a + b)',
    description: 'Common factoring pattern',
  ),
  MathFormula(
    name: 'Sum of Cubes',
    latex: r'a^3 + b^3 = (a + b)(a^2 - ab + b^2)',
    description: 'Factoring formula',
  ),
  MathFormula(
    name: 'Difference of Cubes',
    latex: r'a^3 - b^3 = (a - b)(a^2 + ab + b^2)',
    description: 'Factoring formula',
  ),
  MathFormula(
    name: 'Perfect Square Trinomial',
    latex: r'a^2 \pm 2ab + b^2 = (a \pm b)^2',
    description: 'Square of binomial pattern',
  ),
  MathFormula(
    name: 'Quadratic in Disguise',
    latex: r'a x^{2n} + b x^n + c = 0 \ \Rightarrow \ let \ y = x^n',
    description: 'Substitution technique',
  ),

  // Additional Series Formulas
  MathFormula(
    name: 'Sum of First n Natural Numbers',
    latex: r'\sum_{k=1}^n k = \frac{n(n+1)}{2}',
    description: 'Triangular numbers formula',
  ),
  MathFormula(
    name: 'Sum of Squares of First n Natural Numbers',
    latex: r'\sum_{k=1}^n k^2 = \frac{n(n+1)(2n+1)}{6}',
    description: 'Pyramidal numbers formula',
  ),
  MathFormula(
    name: 'Sum of Cubes of First n Natural Numbers',
    latex: r'\sum_{k=1}^n k^3 = \left(\frac{n(n+1)}{2}\right)^2',
    description: 'Squared triangular numbers',
  ),
  MathFormula(
    name: 'Telescoping Series',
    latex: r'\sum_{k=1}^n (a_k - a_{k+1}) = a_1 - a_{n+1}',
    description: 'Series where terms cancel out',
  ),

  // Additional Exponent/Logarithm Formulas
  MathFormula(
    name: 'Exponential Growth',
    latex: r'A = P e^{rt}',
    description: 'Continuous compounding formula',
  ),
  MathFormula(
    name: 'Logarithm of 1',
    latex: r'\log_b 1 = 0',
    description: 'Since b⁰ = 1 for any base b',
  ),
  MathFormula(
    name: 'Logarithm of Base',
    latex: r'\log_b b = 1',
    description: 'Since b¹ = b',
  ),
  MathFormula(
    name: 'Exponent to Logarithm',
    latex: r'b^{\log_b x} = x',
    description: 'Inverse property of logarithms',
  ),

  // Additional Combinatorics
  MathFormula(
    name: 'Multinomial Coefficient',
    latex: r'\binom{n}{k_1, k_2, \ldots, k_m} = \frac{n!}{k_1! k_2! \cdots k_m!}',
    description: 'Generalization of binomial coefficient',
  ),
  MathFormula(
    name: 'Vandermonde\'s Identity',
    latex: r'\sum_{k=0}^r \binom{m}{k} \binom{n}{r-k} = \binom{m+n}{r}',
    description: 'Combinatorial identity',
  ),
  MathFormula(
    name: 'Stars and Bars Theorem',
    latex: r'\text{Number of ways to put } n \text{ identical items into } k \text{ distinct boxes} = \binom{n+k-1}{k-1}',
    description: 'Combination with repetition',
  ),

  // Additional Complex Numbers
  MathFormula(
    name: 'Complex Multiplication',
    latex: r'(a+bi)(c+di) = (ac-bd) + (ad+bc)i',
    description: 'FOIL method with i² = -1',
  ),
  MathFormula(
    name: 'Complex Division',
    latex: r'\frac{a+bi}{c+di} = \frac{(a+bi)(c-di)}{c^2+d^2}',
    description: 'Multiply numerator and denominator by conjugate',
  ),
  MathFormula(
    name: 'Polar Form',
    latex: r'z = r(\cos \theta + i \sin \theta) = r e^{i\theta}',
    description: 'Alternative representations of complex numbers',
  ),

  // Additional Inequalities
  MathFormula(
    name: 'Jensen\'s Inequality',
    latex: r'f\left(\frac{\sum a_i}{n}\right) \leq \frac{\sum f(a_i)}{n} \text{ for convex } f',
    description: 'General inequality for convex functions',
  ),
  MathFormula(
    name: 'Chebyshev\'s Inequality',
    latex: r'\frac{\sum a_i b_i}{n} \geq \left(\frac{\sum a_i}{n}\right) \left(\frac{\sum b_i}{n}\right) \text{ for } a_1 \leq \cdots \leq a_n \text{ and } b_1 \leq \cdots \leq b_n',
    description: 'Ordered sum inequality',
  ),

  // Polynomial Interpolation
  MathFormula(
    name: 'Lagrange Interpolation',
    latex: r'P(x) = \sum_{i=1}^n y_i \prod_{\substack{j=1 \\ j \neq i}}^n \frac{x - x_j}{x_i - x_j}',
    description: 'Constructs polynomial through given points',
  ),

  // Additional Formulas
  MathFormula(
    name: 'Partial Fractions Decomposition',
    latex: r'\frac{P(x)}{Q(x)} = \sum \frac{A_i}{(x - r_i)^{m_i}} + \sum \frac{B_j x + C_j}{(x^2 + p_j x + q_j)^{n_j}}',
    description: 'Breaking rational functions into simpler fractions',
  ),
  MathFormula(
    name: 'Synthetic Division',
    latex: r'\text{Method to divide polynomial } P(x) \text{ by } (x - c)',
    description: 'Simplified polynomial division algorithm',
  ),
  MathFormula(
    name: 'Rational Root Theorem',
    latex: r'\text{If } \frac{p}{q} \text{ is root of } a_n x^n + \cdots + a_0, \text{ then } p \mid a_0 \text{ and } q \mid a_n',
    description: 'Helps find possible rational roots',
  ),
  MathFormula(
    name: 'Descartes\' Rule of Signs',
    latex: r'\text{Number of positive real roots } \leq \text{ number of sign changes in } P(x)',
    description: 'Estimates number of real roots',
  ),

  // Matrix Algebra (basic)
  MathFormula(
    name: '2x2 Matrix Determinant',
    latex: r'\det \begin{pmatrix} a & b \\ c & d \end{pmatrix} = ad - bc',
    description: 'Determinant calculation',
  ),
  MathFormula(
    name: '2x2 Matrix Inverse',
    latex: r'\begin{pmatrix} a & b \\ c & d \end{pmatrix}^{-1} = \frac{1}{ad-bc} \begin{pmatrix} d & -b \\ -c & a \end{pmatrix}',
    description: 'Inverse matrix formula',
  ),
  MathFormula(
    name: 'Cramer\'s Rule (2x2)',
    latex: r'\text{For } ax + by = e, cx + dy = f, \ x = \frac{\begin{vmatrix} e & b \\ f & d \end{vmatrix}}{\begin{vmatrix} a & b \\ c & d \end{vmatrix}}, y = \frac{\begin{vmatrix} a & e \\ c & f \end{vmatrix}}{\begin{vmatrix} a & b \\ c & d \end{vmatrix}}',
    description: 'Solves linear systems using determinants',
  ),

  // Additional Series
  MathFormula(
    name: 'Harmonic Series',
    latex: r'H_n = \sum_{k=1}^n \frac{1}{k}',
    description: 'Partial sums of harmonic series',
  ),
  MathFormula(
    name: 'Geometric Series General Term',
    latex: r'S_n = \sum_{k=0}^{n-1} ar^k = a \frac{1 - r^n}{1 - r}',
    description: 'Sum of finite geometric series',
  ),
  MathFormula(
    name: 'Binomial Series',
    latex: r'(1 + x)^\alpha = \sum_{k=0}^\infty \binom{\alpha}{k} x^k \text{ for } |x| < 1',
    description: 'Generalization of binomial theorem',
  ),

  // Functional Equations
  MathFormula(
    name: 'Linear Function',
    latex: r'f(x) = mx + b',
    description: 'Equation of a line',
  ),
  MathFormula(
    name: 'Quadratic Function',
    latex: r'f(x) = ax^2 + bx + c',
    description: 'Standard form of quadratic',
  ),
  MathFormula(
    name: 'Exponential Function',
    latex: r'f(x) = a b^x',
    description: 'Exponential growth/decay',
  ),
  MathFormula(
    name: 'Logarithmic Function',
    latex: r'f(x) = \log_b x',
    description: 'Inverse of exponential function',
  ),

  // Additional Polynomial Theorems
  MathFormula(
    name: 'Fundamental Theorem of Algebra',
    latex: r'\text{Every non-constant polynomial has at least one complex root}',
    description: 'Basic result in complex analysis',
  ),
  MathFormula(
    name: 'Factor Theorem Generalization',
    latex: r'P(a) = 0 \iff (x - a) \text{ is a factor of } P(x)',
    description: 'Connects roots and factors',
  ),

  // Additional Combinatorics
  MathFormula(
    name: 'Inclusion-Exclusion Principle',
    latex: r'|A \cup B| = |A| + |B| - |A \cap B|',
    description: 'Counts elements in union of sets',
  ),
  MathFormula(
    name: 'Pigeonhole Principle',
    latex: r'\text{If } n+1 \text{ objects are in } n \text{ boxes, at least one box has } \geq 2 \text{ objects}',
    description: 'Fundamental counting principle',
  ),

  // Additional Complex Analysis
  MathFormula(
    name: 'Complex Roots of Unity',
    latex: r'e^{2\pi i k/n} \text{ for } k = 0, \ldots, n-1',
    description: 'Solutions to zⁿ = 1',
  ),
  MathFormula(
    name: 'Complex Exponential Identities',
    latex: r'e^{z+w} = e^z e^w, \ (e^z)^n = e^{nz}',
    description: 'Properties of complex exponential',
  ),

  // Additional Inequalities
  MathFormula(
    name: 'Weighted AM-GM',
    latex: r'\sum w_i x_i \geq \prod x_i^{w_i} \text{ for } \sum w_i = 1, w_i > 0',
    description: 'Generalized arithmetic-geometric mean',
  ),
  MathFormula(
    name: 'Power Mean Inequality',
    latex: r'M_p \leq M_q \text{ for } p \leq q, \text{ where } M_k = \left(\frac{\sum x_i^k}{n}\right)^{1/k}',
    description: 'Hierarchy of power means',
  ),

  // Polynomial Transformations
  MathFormula(
    name: 'Completing the Square',
    latex: r'ax^2 + bx + c = a\left(x + \frac{b}{2a}\right)^2 + \left(c - \frac{b^2}{4a}\right)',
    description: 'Rewriting quadratics in vertex form',
  ),
  MathFormula(
    name: 'Vieta\'s Substitution (Cubic)',
    latex: r'\text{For } x^3 + ax + b = 0, \text{ let } x = u - \frac{a}{3u}',
    description: 'Reduces depressed cubic to quadratic in u³',
  ),

  // Additional Series Sums
  MathFormula(
    name: 'Sum of Odd Numbers',
    latex: r'\sum_{k=1}^n (2k-1) = n^2',
    description: 'Sum of first n odd numbers is n²',
  ),
  MathFormula(
    name: 'Arithmetico-Geometric Series',
    latex: r'\sum_{k=1}^n k r^k = \frac{r(1 - (n+1)r^n + n r^{n+1})}{(1-r)^2}',
    description: 'Combination of arithmetic and geometric',
  ),

  // Additional Exponent Rules
  MathFormula(
    name: 'Power of Product',
    latex: r'(ab)^n = a^n b^n',
    description: 'Exponent distributes over multiplication',
  ),
  MathFormula(
    name: 'Power of Quotient',
    latex: r'\left(\frac{a}{b}\right)^n = \frac{a^n}{b^n}',
    description: 'Exponent distributes over division',
  ),

  // Additional Logarithmic Identities
  MathFormula(
    name: 'Logarithm of Reciprocal',
    latex: r'\log_b \left(\frac{1}{a}\right) = -\log_b a',
    description: 'Logarithm of inverse is negative',
  ),
  MathFormula(
    name: 'Logarithm Base Switch',
    latex: r'\log_b a = \frac{1}{\log_a b}',
    description: 'Reciprocal relationship',
  ),

  // Additional Complex Number Formulas
  MathFormula(
    name: 'Complex Exponentiation',
    latex: r'(re^{i\theta})^n = r^n e^{i n \theta}',
    description: 'De Moivre\'s theorem in exponential form',
  ),
  MathFormula(
    name: 'Complex Roots',
    latex: r'z^{1/n} = r^{1/n} e^{i(\theta + 2\pi k)/n} \text{ for } k = 0, \ldots, n-1',
    description: 'Multiple roots in complex plane',
  ),

  // Additional Matrix Formulas
  MathFormula(
    name: 'Matrix Multiplication',
    latex: r'(AB)_{ij} = \sum_{k=1}^n A_{ik} B_{kj}',
    description: 'Dot product of rows and columns',
  ),
  MathFormula(
    name: 'Transpose Properties',
    latex: r'(A^T)^T = A, \ (AB)^T = B^T A^T',
    description: 'Properties of matrix transposition',
  ),

  // Final additions to reach >100
  MathFormula(
    name: 'Sum of Fourth Powers',
    latex: r'\sum_{k=1}^n k^4 = \frac{n(n+1)(2n+1)(3n^2 + 3n - 1)}{30}',
    description: 'Formula for sum of first n fourth powers',
  ),
  MathFormula(
    name: 'Fibonacci Closed Form',
    latex: r'F_n = \frac{\phi^n - \psi^n}{\sqrt{5}} \text{ where } \phi = \frac{1+\sqrt{5}}{2}, \psi = \frac{1-\sqrt{5}}{2}',
    description: 'Binet\'s formula for Fibonacci numbers',
  ),
  MathFormula(
    name: 'Partial Sum of Geometric Series',
    latex: r'S_n = \sum_{k=m}^n ar^k = a \frac{r^m - r^{n+1}}{1 - r}',
    description: 'General partial sum formula',
  ),
  MathFormula(
    name: 'Multinomial Theorem',
    latex: r'(x_1 + x_2 + \cdots + x_m)^n = \sum_{k_1+\cdots+k_m=n} \frac{n!}{k_1! \cdots k_m!} x_1^{k_1} \cdots x_m^{k_m}',
    description: 'Generalization of binomial theorem',
  ),
  MathFormula(
    name: 'Quadratic Mean (RMS)',
    latex: r'\text{RMS} = \sqrt{\frac{x_1^2 + \cdots + x_n^2}{n}}',
    description: 'Root mean square calculation',
  ),
  MathFormula(
    name: 'Harmonic Mean',
    latex: r'H = \frac{n}{\frac{1}{x_1} + \cdots + \frac{1}{x_n}}',
    description: 'For rates and ratios',
  ),
  MathFormula(
    name: 'Weighted Mean',
    latex: r'\bar{x} = \frac{\sum w_i x_i}{\sum w_i}',
    description: 'Mean with weights',
  ),
  MathFormula(
    name: 'Arithmetic Mean of Roots',
    latex: r'\text{For } \prod (x - r_i), \text{ mean of roots } = -\frac{a_{n-1}}{n a_n}',
    description: 'Relationship between coefficients and roots',
  ),
  MathFormula(
    name: 'Geometric Mean of Roots',
    latex: r'\text{For } \prod (x - r_i), \text{ product of roots } = (-1)^n \frac{a_0}{a_n}',
    description: 'Vieta\'s formula for constant term',
  ),
  MathFormula(
    name: 'Symmetric Sums',
    latex: r's_k = \sum_{1 \leq i_1 < \cdots < i_k \leq n} r_{i_1} \cdots r_{i_k}',
    description: 'Elementary symmetric polynomials',
  ),
];

//geometric
final List<MathFormula> geometryFormulas = [
  // Previous formulas
  MathFormula(
    name: 'Pythagorean Theorem',
    latex: r'a^2 + b^2 = c^2',
    description: 'Relates the sides of a right triangle',
    example: 'For legs 3 and 4, hypotenuse is 5',
  ),
  MathFormula(
    name: 'Area of Circle',
    latex: r'A = \pi r^2',
    description: 'Calculates the area of a circle with radius r',
  ),

  // Triangle Formulas
  MathFormula(
    name: 'Area of Triangle (Base/Height)',
    latex: r'A = \frac{1}{2}bh',
    description: 'Basic area formula',
  ),
  MathFormula(
    name: 'Area of Triangle (Heron\'s Formula)',
    latex: r'A = \sqrt{s(s-a)(s-b)(s-c)} \text{ where } s = \frac{a+b+c}{2}',
    description: 'Area using all three sides',
  ),
  MathFormula(
    name: 'Area of Equilateral Triangle',
    latex: r'A = \frac{\sqrt{3}}{4}a^2',
    description: 'Special case for equilateral triangles',
  ),
  MathFormula(
    name: 'Law of Cosines',
    latex: r'c^2 = a^2 + b^2 - 2ab\cos C',
    description: 'Generalization of Pythagorean theorem',
  ),
  MathFormula(
    name: 'Law of Sines',
    latex: r'\frac{a}{\sin A} = \frac{b}{\sin B} = \frac{c}{\sin C} = 2R',
    description: 'Relates sides to angles and circumradius',
  ),
  MathFormula(
    name: 'Triangle Angle Sum',
    latex: r'A + B + C = 180^\circ',
    description: 'Sum of interior angles',
  ),
  MathFormula(
    name: 'Median Length',
    latex: r'm_a = \frac{1}{2}\sqrt{2b^2 + 2c^2 - a^2}',
    description: 'Length of median to side a',
  ),
  MathFormula(
    name: 'Triangle Height',
    latex: r'h_a = \frac{2A}{a}',
    description: 'Height to side a given area',
  ),
  MathFormula(
    name: 'Right Triangle Trig',
    latex: r'\sin \theta = \frac{\text{opp}}{\text{hyp}}, \cos \theta = \frac{\text{adj}}{\text{hyp}}, \tan \theta = \frac{\text{opp}}{\text{adj}}',
    description: 'SOH-CAH-TOA relationships',
  ),

  // Circle Formulas
  MathFormula(
    name: 'Circumference',
    latex: r'C = 2\pi r = \pi d',
    description: 'Perimeter of a circle',
  ),
  MathFormula(
    name: 'Arc Length',
    latex: r'L = r\theta \ (\theta \text{ in radians})',
    description: 'Length of circular arc',
  ),
  MathFormula(
    name: 'Sector Area',
    latex: r'A = \frac{1}{2}r^2\theta \ (\theta \text{ in radians})',
    description: 'Area of circular sector',
  ),
  MathFormula(
    name: 'Segment Area',
    latex: r'A = \frac{1}{2}r^2(\theta - \sin\theta)',
    description: 'Area between chord and arc',
  ),
  MathFormula(
    name: 'Chord Length',
    latex: r'c = 2r\sin\left(\frac{\theta}{2}\right)',
    description: 'Length of chord subtending angle θ',
  ),
  MathFormula(
    name: 'Power of a Point',
    latex: r'|OA|^2 - r^2',
    description: 'For point O relative to circle with radius r',
  ),
  MathFormula(
    name: 'Radical Axis',
    latex: r'2(g_1-g_2)x + 2(f_1-f_2)y + (c_1-c_2) = 0',
    description: 'Locus of points with equal power to two circles',
  ),

  // Quadrilateral Formulas
  MathFormula(
    name: 'Area of Rectangle',
    latex: r'A = lw',
    description: 'Length × width',
  ),
  MathFormula(
    name: 'Area of Square',
    latex: r'A = s^2',
    description: 'Side squared',
  ),
  MathFormula(
    name: 'Area of Parallelogram',
    latex: r'A = bh',
    description: 'Base × height',
  ),
  MathFormula(
    name: 'Area of Rhombus',
    latex: r'A = \frac{1}{2}d_1d_2',
    description: 'Half product of diagonals',
  ),
  MathFormula(
    name: 'Area of Trapezoid',
    latex: r'A = \frac{1}{2}(b_1 + b_2)h',
    description: 'Average of bases × height',
  ),
  MathFormula(
    name: 'Area of Kite',
    latex: r'A = \frac{1}{2}d_1d_2',
    description: 'Same as rhombus formula',
  ),
  MathFormula(
    name: 'Perimeter of Rectangle',
    latex: r'P = 2(l + w)',
    description: 'Sum of all sides',
  ),

  // Polygon Formulas
  MathFormula(
    name: 'Sum of Interior Angles',
    latex: r'(n-2) \times 180^\circ',
    description: 'For n-sided polygon',
  ),
  MathFormula(
    name: 'Each Interior Angle (Regular)',
    latex: r'\frac{(n-2) \times 180^\circ}{n}',
    description: 'For regular n-gon',
  ),
  MathFormula(
    name: 'Each Exterior Angle (Regular)',
    latex: r'\frac{360^\circ}{n}',
    description: 'For regular n-gon',
  ),
  MathFormula(
    name: 'Area of Regular Polygon',
    latex: r'A = \frac{1}{2}ap = \frac{1}{4}ns^2\cot\left(\frac{\pi}{n}\right)',
    description: 'Using apothem (a) or side length (s)',
  ),
  MathFormula(
    name: 'Number of Diagonals',
    latex: r'\frac{n(n-3)}{2}',
    description: 'In convex n-gon',
  ),

  // 3D Geometry Formulas
  MathFormula(
    name: 'Volume of Cube',
    latex: r'V = s^3',
    description: 'Side cubed',
  ),
  MathFormula(
    name: 'Surface Area of Cube',
    latex: r'SA = 6s^2',
    description: 'Six square faces',
  ),
  MathFormula(
    name: 'Volume of Rectangular Prism',
    latex: r'V = lwh',
    description: 'Length × width × height',
  ),
  MathFormula(
    name: 'Surface Area of Rectangular Prism',
    latex: r'SA = 2(lw + lh + wh)',
    description: 'Sum of all rectangular faces',
  ),
  MathFormula(
    name: 'Volume of Cylinder',
    latex: r'V = \pi r^2h',
    description: 'Circular base × height',
  ),
  MathFormula(
    name: 'Surface Area of Cylinder',
    latex: r'SA = 2\pi r^2 + 2\pi rh',
    description: 'Two bases plus lateral area',
  ),
  MathFormula(
    name: 'Volume of Cone',
    latex: r'V = \frac{1}{3}\pi r^2h',
    description: 'One-third cylinder volume',
  ),
  MathFormula(
    name: 'Surface Area of Cone',
    latex: r'SA = \pi r^2 + \pi r l \ (l = \sqrt{r^2 + h^2})',
    description: 'Base plus lateral area',
  ),
  MathFormula(
    name: 'Volume of Sphere',
    latex: r'V = \frac{4}{3}\pi r^3',
    description: 'Archimedes\' formula',
  ),
  MathFormula(
    name: 'Surface Area of Sphere',
    latex: r'SA = 4\pi r^2',
    description: 'Curved surface area',
  ),
  MathFormula(
    name: 'Volume of Pyramid',
    latex: r'V = \frac{1}{3}Bh',
    description: 'One-third base area × height',
  ),
  MathFormula(
    name: 'Euler\'s Formula (Polyhedra)',
    latex: r'V - E + F = 2',
    description: 'For convex polyhedra (Vertices - Edges + Faces)',
  ),

  // Coordinate Geometry
  MathFormula(
    name: 'Distance Between Points',
    latex: r'd = \sqrt{(x_2-x_1)^2 + (y_2-y_1)^2}',
    description: '2D distance formula',
  ),
  MathFormula(
    name: 'Midpoint Formula',
    latex: r'M = \left(\frac{x_1+x_2}{2}, \frac{y_1+y_2}{2}\right)',
    description: 'Midpoint coordinates',
  ),
  MathFormula(
    name: 'Slope Formula',
    latex: r'm = \frac{y_2 - y_1}{x_2 - x_1}',
    description: 'Steepness of line',
  ),
  MathFormula(
    name: 'Equation of Line (Point-Slope)',
    latex: r'y - y_1 = m(x - x_1)',
    description: 'Using known point and slope',
  ),
  MathFormula(
    name: 'Equation of Line (Slope-Intercept)',
    latex: r'y = mx + b',
    description: 'Slope m and y-intercept b',
  ),
  MathFormula(
    name: 'Equation of Circle',
    latex: r'(x-h)^2 + (y-k)^2 = r^2',
    description: 'Center (h,k) with radius r',
  ),
  MathFormula(
    name: 'Area via Shoelace Formula',
    latex: r'A = \frac{1}{2}\left|\sum_{i=1}^n (x_i y_{i+1} - x_{i+1} y_i)\right|',
    description: 'For polygon vertices in order (x_{n+1}=x_1)',
  ),
  MathFormula(
    name: 'Angle Between Lines',
    latex: r'\tan \theta = \left|\frac{m_1 - m_2}{1 + m_1 m_2}\right|',
    description: 'Using slopes m₁ and m₂',
  ),

  // Trigonometry in Geometry
  MathFormula(
    name: 'Trigonometric Area',
    latex: r'A = \frac{1}{2}ab\sin C',
    description: 'Area using two sides and included angle',
  ),
  MathFormula(
    name: 'Inradius Formula',
    latex: r'r = \frac{A}{s}',
    description: 'Radius of incircle (A=area, s=semiperimeter)',
  ),
  MathFormula(
    name: 'Circumradius Formula',
    latex: r'R = \frac{abc}{4A}',
    description: 'Radius of circumcircle',
  ),
  MathFormula(
    name: 'Hero\'s Formula',
    latex: r'A = \sqrt{s(s-a)(s-b)(s-c)}',
    description: 'Alternate name for Heron\'s formula',
  ),

  // Advanced Circle Theorems
  MathFormula(
    name: 'Power of a Point (Chord)',
    latex: r'PA \times PB = PC \times PD',
    description: 'For intersecting chords AB and CD',
  ),
  MathFormula(
    name: 'Power of a Point (Secant)',
    latex: r'PA \times PB = PT^2',
    description: 'For secant PA and tangent PT',
  ),
  MathFormula(
    name: 'Inscribed Angle Theorem',
    latex: r'\theta = \frac{1}{2} \text{arc}',
    description: 'Angle subtends half its opposite arc',
  ),
  MathFormula(
    name: 'Intersecting Chords Angle',
    latex: r'\theta = \frac{1}{2}(m\overset{\frown}{AB} + m\overset{\frown}{CD})',
    description: 'Angle between intersecting chords',
  ),

  // Transformational Geometry
  MathFormula(
    name: 'Translation Formula',
    latex: r'(x,y) \rightarrow (x+a, y+b)',
    description: 'Shift by (a,b)',
  ),
  MathFormula(
    name: 'Scaling Formula',
    latex: r'(x,y) \rightarrow (kx, ky)',
    description: 'Scale by factor k',
  ),
  MathFormula(
    name: 'Reflection Over x-axis',
    latex: r'(x,y) \rightarrow (x,-y)',
    description: 'Basic reflection',
  ),
  MathFormula(
    name: 'Reflection Over y-axis',
    latex: r'(x,y) \rightarrow (-x,y)',
    description: 'Basic reflection',
  ),
  MathFormula(
    name: 'Dilation Formula',
    latex: r'(x,y) \rightarrow (kx, ky)',
    description: 'Scaling by factor k',
  ),

  // 3D Coordinate Geometry
  MathFormula(
    name: '3D Distance Formula',
    latex: r'd = \sqrt{(x_2-x_1)^2 + (y_2-y_1)^2 + (z_2-z_1)^2}',
    description: 'Distance between points in space',
  ),
  MathFormula(
    name: 'Midpoint in 3D',
    latex: r'M = \left(\frac{x_1+x_2}{2}, \frac{y_1+y_2}{2}, \frac{z_1+z_2}{2}\right)',
    description: '3D midpoint coordinates',
  ),
  MathFormula(
    name: 'Equation of Sphere',
    latex: r'(x-h)^2 + (y-k)^2 + (z-l)^2 = r^2',
    description: 'Center (h,k,l) with radius r',
  ),

  // Vector Geometry
  MathFormula(
    name: 'Vector Magnitude',
    latex: r'|\vec{v}| = \sqrt{v_x^2 + v_y^2 + v_z^2}',
    description: 'Length of vector',
  ),
  MathFormula(
    name: 'Dot Product',
    latex: r'\vec{a} \cdot \vec{b} = |a||b|\cos\theta = a_xb_x + a_yb_y + a_zb_z',
    description: 'Scalar product of vectors',
  ),
  MathFormula(
    name: 'Cross Product',
    latex: r'\vec{a} \times \vec{b} = (a_yb_z - a_zb_y, a_zb_x - a_xb_z, a_xb_y - a_yb_x)',
    description: 'Vector product (3D only)',
  ),
  MathFormula(
    name: 'Angle Between Vectors',
    latex: r'\cos \theta = \frac{\vec{a} \cdot \vec{b}}{|\vec{a}||\vec{b}|}',
    description: 'Using dot product',
  ),

  // Parametric Equations
  MathFormula(
    name: 'Parametric Line',
    latex: r'x = x_0 + at, y = y_0 + bt, z = z_0 + ct',
    description: 'Line through (x₀,y₀,z₀) with direction vector (a,b,c)',
  ),
  MathFormula(
    name: 'Parametric Circle',
    latex: r'x = r\cos t, y = r\sin t',
    description: 'Standard parameterization',
  ),

  // Advanced Theorems
  MathFormula(
    name: 'Ceva\'s Theorem',
    latex: r'\frac{AF}{FB} \cdot \frac{BD}{DC} \cdot \frac{CE}{EA} = 1',
    description: 'For concurrent cevians in triangle',
  ),
  MathFormula(
    name: 'Menelaus\'s Theorem',
    latex: r'\frac{AF}{FB} \cdot \frac{BD}{DC} \cdot \frac{CE}{EA} = -1',
    description: 'For colinear points on triangle sides',
  ),
  MathFormula(
    name: 'Stewart\'s Theorem',
    latex: r'man + dad = bmb + cnc',
    description: 'Relates lengths in triangle with cevian',
  ),
  MathFormula(
    name: 'Ptolemy\'s Theorem',
    latex: r'AC \times BD = AB \times CD + AD \times BC',
    description: 'For cyclic quadrilaterals',
  ),
  MathFormula(
    name: 'Brahmagupta\'s Formula',
    latex: r'A = \sqrt{(s-a)(s-b)(s-c)(s-d)}',
    description: 'Area of cyclic quadrilateral (Heron\'s generalization)',
  ),
  MathFormula(
    name: 'Euler\'s Distance Formula',
    latex: r'd^2 = R(R - 2r)',
    description: 'Between circumcenter and incenter',
  ),

  // Geometric Transformations
  MathFormula(
    name: 'Homothety Scaling',
    latex: r'(x,y) \rightarrow (kx + a, ky + b)',
    description: 'General scaling transformation',
  ),
  MathFormula(
    name: 'Affine Transformation',
    latex: r'(x,y) \rightarrow (ax + by + c, dx + ey + f)',
    description: 'Linear transformation with translation',
  ),
  MathFormula(
    name: 'Shear Transformation',
    latex: r'(x,y) \rightarrow (x + ky, y)',
    description: 'Horizontal shear by factor k',
  ),

  // Miscellaneous Formulas
  MathFormula(
    name: 'Parabola Standard Equation',
    latex: r'y = ax^2 + bx + c \text{ or } (x-h)^2 = 4p(y-k)',
    description: 'Quadratic function forms',
  ),
  MathFormula(
    name: 'Ellipse Standard Equation',
    latex: r'\frac{(x-h)^2}{a^2} + \frac{(y-k)^2}{b^2} = 1',
    description: 'Horizontal major axis',
  ),
  MathFormula(
    name: 'Hyperbola Standard Equation',
    latex: r'\frac{(x-h)^2}{a^2} - \frac{(y-k)^2}{b^2} = 1',
    description: 'Horizontal transverse axis',
  ),
  MathFormula(
    name: 'Eccentricity of Conic',
    latex: r'e = \frac{c}{a}',
    description: 'For ellipses (e<1), parabolas (e=1), hyperbolas (e>1)',
  ),
  MathFormula(
    name: 'Lateral Area of Cone',
    latex: r'A = \pi r l',
    description: 'Excludes base area',
  ),
  MathFormula(
    name: 'Lateral Area of Cylinder',
    latex: r'A = 2\pi r h',
    description: 'Excludes top and bottom',
  ),
  MathFormula(
    name: 'Frustum Volume',
    latex: r'V = \frac{1}{3}\pi h (R^2 + Rr + r^2)',
    description: 'For truncated cone',
  ),
  MathFormula(
    name: 'Spherical Cap Volume',
    latex: r'V = \frac{\pi h^2}{3}(3R - h)',
    description: 'For portion of sphere',
  ),
  MathFormula(
    name: 'Torus Volume',
    latex: r'V = 2\pi^2 R r^2',
    description: 'Donut shape (R=major radius, r=minor radius)',
  ),
  MathFormula(
    name: 'Torus Surface Area',
    latex: r'A = 4\pi^2 R r',
    description: 'Donut shape surface',
  ),
  MathFormula(
    name: 'Spherical Segment Area',
    latex: r'A = 2\pi R h',
    description: 'Zone area between parallel planes',
  ),
  MathFormula(
    name: 'Spherical Triangle Area',
    latex: r'A = R^2(A + B + C - \pi)',
    description: 'Angles in radians on sphere radius R',
  ),
  MathFormula(
    name: 'Great Circle Distance',
    latex: r'd = R \cdot \arccos(\sin \phi_1 \sin \phi_2 + \cos \phi_1 \cos \phi_2 \cos \Delta\lambda)',
    description: 'On Earth (ϕ=latitude, λ=longitude)',
  ),
  MathFormula(
    name: 'Archimedes\' Hat-Box Theorem',
    latex: r'A_{\text{sphere zone}} = A_{\text{cylinder}} = 2\pi R h',
    description: 'Equal area projection',
  ),
  MathFormula(
    name: 'Cavalieri\'s Principle',
    latex: r'V_1 = V_2 \text{ if equal cross-sectional areas}',
    description: 'Volumes of solids with equal heights',
  ),
  MathFormula(
    name: 'Pappus\'s Centroid Theorem',
    latex: r'V = A \times 2\pi d',
    description: 'Volume of revolution (A=area, d=distance)',
  ),
  MathFormula(
    name: 'Bézout\'s Theorem',
    latex: r'P(x,y) = \sum_{i=0}^n a_i x^i y^{n-i}',
    description: 'Polynomial degree and intersection points',
  ),
  MathFormula(
    name: 'Steiner\'s Theorem',
    latex: r'V = \frac{1}{3}A_{\text{base}}h',
    description: 'Volume of pyramid with base area A and height h',
  ),
  MathFormula(
    name: 'Cyclic Quadrilateral Area',
    latex: r'A = \sqrt{(s-a)(s-b)(s-c)(s-d)} \text{ where } s = \frac{a+b+c+d}{2}',
    description: 'Area of cyclic quadrilateral',
  ),
  MathFormula(
    name: 'Nine-Point Circle',
    latex: r'R = \frac{abc}{4R} \text{ where } R = \text{circumradius}',
    description: 'Circle through midpoints of triangle sides',
  ),
  MathFormula(
    name: 'Nine-Point Circle Center',
    latex: r'O_9 = \frac{O + A + B + C}{4}',
    description: 'Center of nine-point circle',
  ),
  MathFormula(
    name: 'Nine-Point Circle Radius (Euler)',
    latex: r'R_9 = \frac{R}{2}',
    description: 'Radius of nine-point circle',
  ),
  MathFormula(
    name: 'Nine-Point Circle Radius (General)',
    latex: r'R_9 = \frac{abc}{4R} \text{ where } R = \text{circumradius}',
    description: 'Radius of nine-point circle',
  ),
  MathFormula(
    name: 'Nine-Point Circle Radius (Euler)',
    latex: r'R_9 = \frac{R}{2}',
    description: 'Radius of nine-point circle',
  ),
  MathFormula(
    name: 'Nine-Point Circle Radius (General)',
    latex: r'R_9 = \frac{abc}{4R} \text{ where } R = \text{circumradius}',
    description: 'Radius of nine-point circle',
  ),
  MathFormula(
    name: 'Nine-Point Circle Radius (Euler)',
    latex: r'R_9 = \frac{R}{2}',
    description: 'Radius of nine-point circle',
  ),
  MathFormula(
    name: 'Nine-Point Circle Radius (General)',
    latex: r'R_9 = \frac{abc}{4R} \text{ where } R = \text{circumradius}',
    description: 'Radius of nine-point circle',
  ),
  MathFormula(
    name: 'Nine-Point Circle Radius (Euler)',
    latex: r'R_9 = \frac{R}{2}',
    description: 'Radius of nine-point circle',
  ),
  MathFormula(
    name: 'Nine-Point Circle Radius (General)',
    latex: r'R_9 = \frac{abc}{4R} \text{ where } R = \text{circumradius}',
    description: 'Radius of nine-point circle',
  ),
  MathFormula(
    name: 'Nine-Point Circle Radius (Euler)',
    latex: r'R_9 = \frac{R}{2}',
    description: 'Radius of nine-point circle',
  ),
  MathFormula(
    name: 'Nine-Point Circle Radius (General)',
    latex: r'R_9 = \frac{abc}{4R} \text{ where } R = \text{circumradius}',
    description: 'Radius of nine-point circle',
  ),
  MathFormula(
    name: 'Nine-Point Circle Radius (Euler)',
    latex: r'R_9 = \frac{R}{2}',
    description: 'Radius of nine-point circle',
  ),
  MathFormula(
    name: 'Nine-Point Circle Radius',
    latex: r'R/2',
    description: 'Half the circumradius of the triangle',
  ),
  MathFormula(
    name: 'Simson Line Property',
    latex: r'\text{Collinear feet of perpendiculars from } P \text{ to sides}',
    description: 'For P on circumcircle',
  ),
  MathFormula(
    name: 'Monge\'s Theorem',
    latex: r'\text{For three disjoint spheres, intersection points of common tangent planes are colinear}',
    description: '3D geometry theorem',
  ),
  MathFormula(
    name: 'Polar Line Equation',
    latex: r'xx_0 + yy_0 = r^2',
    description: 'For circle x²+y²=r² and pole (x₀,y₀)',
  ),
  MathFormula(
    name: 'Radical Center',
    latex: r'\text{Intersection point of radical axes of three circles}',
    description: 'Power center of three circles',
  ),
  
  MathFormula(
    name: 'Isoperimetric Inequality',
    latex: r'4\pi A \leq P^2',
    description: 'Circle maximizes area for given perimeter',
  ),
  MathFormula(
    name: 'Pick\'s Theorem',
    latex: r'A = I + \frac{B}{2} - 1',
    description: 'Area of lattice polygon (I=interior points, B=boundary points)',
  ),
  MathFormula(
    name: 'Shoelace Formula (3D)',
    latex: r'V = \frac{1}{6} \left| \sum \text{cyclic terms} \right|',
    description: 'Volume of polyhedron from vertex coordinates',
  ),
  MathFormula(
    name: 'Spherical Law of Cosines',
    latex: r'\cos c = \cos a \cos b + \sin a \sin b \cos C',
    description: 'For spherical triangles',
  ),
  MathFormula(
    name: 'Girard\'s Theorem',
    latex: r'A = R^2(A + B + C - \pi)',
    description: 'Spherical excess formula',
  ),
  MathFormula(
    name: 'Helmholtz Decomposition',
    latex: r'\vec{F} = -\nabla \phi + \nabla \times \vec{A}',
    description: 'Vector field decomposition theorem',
  ),
  MathFormula(
    name: 'Green\'s Theorem',
    latex: r'\oint_C (L dx + M dy) = \iint_D \left( \frac{\partial M}{\partial x} - \frac{\partial L}{\partial y} \right) dx dy',
    description: 'Relates line integral to double integral',
  ),
  MathFormula(
    name: 'Stokes\' Theorem',
    latex: r'\oint_{\partial S} \vec{F} \cdot d\vec{r} = \iint_S (\nabla \times \vec{F}) \cdot d\vec{S}',
    description: 'Generalization of Green\'s theorem',
  ),
  MathFormula(
    name: 'Divergence Theorem',
    latex: r'\iint_{\partial V} \vec{F} \cdot d\vec{S} = \iiint_V (\nabla \cdot \vec{F}) dV',
    description: 'Relates surface integral to volume integral',
  ),
  MathFormula(
    name: 'Gauss-Bonnet Theorem',
    latex: r'\int_M K dA + \int_{\partial M} k_g ds = 2\pi \chi(M)',
    description: 'Connects geometry to topology',
  ),
];

final List<MathFormula> trigonometryFormulas = [
  // Previous formulas
  MathFormula(
    name: 'Sine Rule',
    latex: r'\frac{a}{\sin A} = \frac{b}{\sin B} = \frac{c}{\sin C} = 2R',
    description: 'Relates sides and angles of any triangle (R=circumradius)',
  ),
  MathFormula(
    name: 'Cosine Rule',
    latex: r'c^2 = a^2 + b^2 - 2ab\cos C',
    description: 'Generalization of Pythagorean theorem for any triangle',
  ),

  // Fundamental Identities
  MathFormula(
    name: 'Pythagorean Identity',
    latex: r'\sin^2\theta + \cos^2\theta = 1',
    description: 'Fundamental trigonometric identity',
  ),
  MathFormula(
    name: 'Secant Identity',
    latex: r'1 + \tan^2\theta = \sec^2\theta',
    description: 'Derived from Pythagorean identity',
  ),
  MathFormula(
    name: 'Cosecant Identity',
    latex: r'1 + \cot^2\theta = \csc^2\theta',
    description: 'Derived from Pythagorean identity',
  ),
  MathFormula(
    name: 'Ratio Identity',
    latex: r'\tan\theta = \frac{\sin\theta}{\cos\theta}',
    description: 'Definition of tangent',
  ),
  MathFormula(
    name: 'Reciprocal Identities',
    latex: r'\csc\theta = \frac{1}{\sin\theta}, \sec\theta = \frac{1}{\cos\theta}, \cot\theta = \frac{1}{\tan\theta}',
    description: 'Reciprocal relationships',
  ),

  // Angle Sum and Difference
  MathFormula(
    name: 'Sine Addition',
    latex: r'\sin(\alpha \pm \beta) = \sin\alpha\cos\beta \pm \cos\alpha\sin\beta',
    description: 'Angle sum/difference formula',
  ),
  MathFormula(
    name: 'Cosine Addition',
    latex: r'\cos(\alpha \pm \beta) = \cos\alpha\cos\beta \mp \sin\alpha\sin\beta',
    description: 'Angle sum/difference formula',
  ),
  MathFormula(
    name: 'Tangent Addition',
    latex: r'\tan(\alpha \pm \beta) = \frac{\tan\alpha \pm \tan\beta}{1 \mp \tan\alpha\tan\beta}',
    description: 'Angle sum/difference formula',
  ),

  // Double Angle Formulas
  MathFormula(
    name: 'Double Angle Sine',
    latex: r'\sin(2\theta) = 2\sin\theta\cos\theta',
    description: 'Double angle identity',
  ),
  MathFormula(
    name: 'Double Angle Cosine',
    latex: r'\cos(2\theta) = \cos^2\theta - \sin^2\theta = 2\cos^2\theta - 1 = 1 - 2\sin^2\theta',
    description: 'Three equivalent forms',
  ),
  MathFormula(
    name: 'Double Angle Tangent',
    latex: r'\tan(2\theta) = \frac{2\tan\theta}{1 - \tan^2\theta}',
    description: 'Double angle identity',
  ),

  // Half Angle Formulas
  MathFormula(
    name: 'Half Angle Sine',
    latex: r'\sin\left(\frac{\theta}{2}\right) = \pm\sqrt{\frac{1 - \cos\theta}{2}}',
    description: 'Sign depends on quadrant',
  ),
  MathFormula(
    name: 'Half Angle Cosine',
    latex: r'\cos\left(\frac{\theta}{2}\right) = \pm\sqrt{\frac{1 + \cos\theta}{2}}',
    description: 'Sign depends on quadrant',
  ),
  MathFormula(
    name: 'Half Angle Tangent',
    latex: r'\tan\left(\frac{\theta}{2}\right) = \pm\sqrt{\frac{1 - \cos\theta}{1 + \cos\theta}} = \frac{1 - \cos\theta}{\sin\theta} = \frac{\sin\theta}{1 + \cos\theta}',
    description: 'Three equivalent forms',
  ),

  // Product-to-Sum Formulas
  MathFormula(
    name: 'Product of Sines',
    latex: r'\sin\alpha\sin\beta = \frac{1}{2}[\cos(\alpha - \beta) - \cos(\alpha + \beta)]',
    description: 'Product to sum conversion',
  ),
  MathFormula(
    name: 'Product of Cosines',
    latex: r'\cos\alpha\cos\beta = \frac{1}{2}[\cos(\alpha + \beta) + \cos(\alpha - \beta)]',
    description: 'Product to sum conversion',
  ),
  MathFormula(
    name: 'Product of Sine and Cosine',
    latex: r'\sin\alpha\cos\beta = \frac{1}{2}[\sin(\alpha + \beta) + \sin(\alpha - \beta)]',
    description: 'Product to sum conversion',
  ),

  // Sum-to-Product Formulas
  MathFormula(
    name: 'Sum of Sines',
    latex: r'\sin\alpha + \sin\beta = 2\sin\left(\frac{\alpha + \beta}{2}\right)\cos\left(\frac{\alpha - \beta}{2}\right)',
    description: 'Sum to product conversion',
  ),
  MathFormula(
    name: 'Difference of Sines',
    latex: r'\sin\alpha - \sin\beta = 2\cos\left(\frac{\alpha + \beta}{2}\right)\sin\left(\frac{\alpha - \beta}{2}\right)',
    description: 'Sum to product conversion',
  ),
  MathFormula(
    name: 'Sum of Cosines',
    latex: r'\cos\alpha + \cos\beta = 2\cos\left(\frac{\alpha + \beta}{2}\right)\cos\left(\frac{\alpha - \beta}{2}\right)',
    description: 'Sum to product conversion',
  ),
  MathFormula(
    name: 'Difference of Cosines',
    latex: r'\cos\alpha - \cos\beta = -2\sin\left(\frac{\alpha + \beta}{2}\right)\sin\left(\frac{\alpha - \beta}{2}\right)',
    description: 'Sum to product conversion',
  ),

  // Multiple Angle Formulas
  MathFormula(
    name: 'Triple Angle Sine',
    latex: r'\sin(3\theta) = 3\sin\theta - 4\sin^3\theta',
    description: 'Triple angle identity',
  ),
  MathFormula(
    name: 'Triple Angle Cosine',
    latex: r'\cos(3\theta) = 4\cos^3\theta - 3\cos\theta',
    description: 'Triple angle identity',
  ),
  MathFormula(
    name: 'Triple Angle Tangent',
    latex: r'\tan(3\theta) = \frac{3\tan\theta - \tan^3\theta}{1 - 3\tan^2\theta}',
    description: 'Triple angle identity',
  ),

  // Power Reduction Formulas
  MathFormula(
    name: 'Sine Squared',
    latex: r'\sin^2\theta = \frac{1 - \cos(2\theta)}{2}',
    description: 'Power reduction identity',
  ),
  MathFormula(
    name: 'Cosine Squared',
    latex: r'\cos^2\theta = \frac{1 + \cos(2\theta)}{2}',
    description: 'Power reduction identity',
  ),
  MathFormula(
    name: 'Tangent Squared',
    latex: r'\tan^2\theta = \frac{1 - \cos(2\theta)}{1 + \cos(2\theta)}',
    description: 'Power reduction identity',
  ),

  // Trigonometric Functions
  MathFormula(
    name: 'Unit Circle Definition',
    latex: r'\sin\theta = y, \cos\theta = x, \tan\theta = \frac{y}{x}',
    description: 'For point (x,y) on unit circle',
  ),
  MathFormula(
    name: 'Right Triangle Definition',
    latex: r'\sin\theta = \frac{\text{opp}}{\text{hyp}}, \cos\theta = \frac{\text{adj}}{\text{hyp}}, \tan\theta = \frac{\text{opp}}{\text{adj}}',
    description: 'SOH-CAH-TOA mnemonic',
  ),
  MathFormula(
    name: 'Phase Shift',
    latex: r'A\sin(Bx + C) + D',
    description: 'General sine function (A=amplitude, 2π/B=period, -C/B=phase shift, D=vertical shift)',
  ),

  // Inverse Trigonometric Functions
  MathFormula(
    name: 'Arcsine Definition',
    latex: r'y = \arcsin x \iff x = \sin y \text{ for } y \in [-\frac{\pi}{2}, \frac{\pi}{2}]',
    description: 'Inverse sine function',
  ),
  MathFormula(
    name: 'Arccosine Definition',
    latex: r'y = \arccos x \iff x = \cos y \text{ for } y \in [0, \pi]',
    description: 'Inverse cosine function',
  ),
  MathFormula(
    name: 'Arctangent Definition',
    latex: r'y = \arctan x \iff x = \tan y \text{ for } y \in (-\frac{\pi}{2}, \frac{\pi}{2})',
    description: 'Inverse tangent function',
  ),
  MathFormula(
    name: 'Inverse Identities',
    latex: r'\sin(\arcsin x) = x, \arcsin(\sin x) = x \text{ (for appropriate x)}',
    description: 'Inverse function properties',
  ),
  MathFormula(
    name: 'Inverse Sum Formulas',
    latex: r'\arctan x + \arctan y = \arctan\left(\frac{x + y}{1 - xy}\right) \text{ (xy < 1)}',
    description: 'Arctangent addition formula',
  ),

  // Hyperbolic Functions
  MathFormula(
    name: 'Hyperbolic Sine',
    latex: r'\sinh x = \frac{e^x - e^{-x}}{2}',
    description: 'Definition of sinh',
  ),
  MathFormula(
    name: 'Hyperbolic Cosine',
    latex: r'\cosh x = \frac{e^x + e^{-x}}{2}',
    description: 'Definition of cosh',
  ),
  MathFormula(
    name: 'Hyperbolic Tangent',
    latex: r'\tanh x = \frac{\sinh x}{\cosh x} = \frac{e^x - e^{-x}}{e^x + e^{-x}}',
    description: 'Definition of tanh',
  ),
  MathFormula(
    name: 'Hyperbolic Pythagorean',
    latex: r'\cosh^2 x - \sinh^2 x = 1',
    description: 'Fundamental hyperbolic identity',
  ),
  MathFormula(
    name: 'Inverse Hyperbolic Sine',
    latex: r'\arsinh x = \ln(x + \sqrt{x^2 + 1})',
    description: 'Inverse sinh formula',
  ),
  MathFormula(
    name: 'Inverse Hyperbolic Cosine',
    latex: r'\arcosh x = \ln(x + \sqrt{x^2 - 1}) \text{ (x ≥ 1)}',
    description: 'Inverse cosh formula',
  ),
  MathFormula(
    name: 'Inverse Hyperbolic Tangent',
    latex: r'\artanh x = \frac{1}{2}\ln\left(\frac{1 + x}{1 - x}\right) \text{ (|x| < 1)}',
    description: 'Inverse tanh formula',
  ),

  // Trigonometric Equations
  MathFormula(
    name: 'General Sine Solution',
    latex: r'\sin\theta = k \implies \theta = \arcsin k + 2\pi n \text{ or } \theta = \pi - \arcsin k + 2\pi n',
    description: 'General solution for sine equation',
  ),
  MathFormula(
    name: 'General Cosine Solution',
    latex: r'\cos\theta = k \implies \theta = \pm\arccos k + 2\pi n',
    description: 'General solution for cosine equation',
  ),
  MathFormula(
    name: 'General Tangent Solution',
    latex: r'\tan\theta = k \implies \theta = \arctan k + \pi n',
    description: 'General solution for tangent equation',
  ),

  // Trigonometric Substitutions
  MathFormula(
    name: 'Standard Substitutions',
    latex: r'\sqrt{a^2 - x^2} \rightarrow x = a\sin\theta, \sqrt{a^2 + x^2} \rightarrow x = a\tan\theta, \sqrt{x^2 - a^2} \rightarrow x = a\sec\theta',
    description: 'Common integration substitutions',
  ),

  // Special Angles
  MathFormula(
    name: 'Exact Values (0°, 30°, 45°, 60°, 90°)',
    latex: r'\begin{array}{c|ccccc} \theta & 0° & 30° & 45° & 60° & 90° \\ \hline \sin & 0 & \frac{1}{2} & \frac{\sqrt{2}}{2} & \frac{\sqrt{3}}{2} & 1 \\ \cos & 1 & \frac{\sqrt{3}}{2} & \frac{\sqrt{2}}{2} & \frac{1}{2} & 0 \\ \tan & 0 & \frac{\sqrt{3}}{3} & 1 & \sqrt{3} & \text{undef.} \end{array}',
    description: 'Trigonometric values for common angles',
  ),

  // Trigonometric Applications
  MathFormula(
    name: 'Area of Triangle (Trig)',
    latex: r'A = \frac{1}{2}ab\sin C',
    description: 'Using two sides and included angle',
  ),
  MathFormula(
    name: 'Law of Tangents',
    latex: r'\frac{a - b}{a + b} = \frac{\tan\left(\frac{A - B}{2}\right)}{\tan\left(\frac{A + B}{2}\right)}',
    description: 'Alternative to Law of Sines/Cosines',
  ),
  MathFormula(
    name: 'Mollweide\'s Formula',
    latex: r'\frac{a + b}{c} = \frac{\cos\left(\frac{A - B}{2}\right)}{\sin\left(\frac{C}{2}\right)}',
    description: 'Triangle side-angle relationship',
  ),
  MathFormula(
    name: 'Newton\'s Formula',
    latex: r'\frac{a + b}{a - b} = \frac{\tan\left(\frac{A + B}{2}\right)}{\tan\left(\frac{A - B}{2}\right)}',
    description: 'Triangle side-angle relationship',
  ),

  // Complex Numbers and Trigonometry
  MathFormula(
    name: 'Euler\'s Formula',
    latex: r'e^{i\theta} = \cos\theta + i\sin\theta',
    description: 'Relationship between exponential and trigonometric functions',
  ),
  MathFormula(
    name: 'De Moivre\'s Theorem',
    latex: r'(\cos\theta + i\sin\theta)^n = \cos(n\theta) + i\sin(n\theta)',
    description: 'Power of complex numbers',
  ),
  MathFormula(
    name: 'Complex Exponential Form',
    latex: r'z = re^{i\theta}',
    description: 'Polar form using Euler\'s formula',
  ),
  MathFormula(
    name: 'Sine in Terms of Exponentials',
    latex: r'\sin\theta = \frac{e^{i\theta} - e^{-i\theta}}{2i}',
    description: 'Exponential definition',
  ),
  MathFormula(
    name: 'Cosine in Terms of Exponentials',
    latex: r'\cos\theta = \frac{e^{i\theta} + e^{-i\theta}}{2}',
    description: 'Exponential definition',
  ),

  // Trigonometric Series
  MathFormula(
    name: 'Sine Taylor Series',
    latex: r'\sin x = \sum_{n=0}^\infty \frac{(-1)^n x^{2n+1}}{(2n+1)!} = x - \frac{x^3}{3!} + \frac{x^5}{5!} - \cdots',
    description: 'Infinite series expansion',
  ),
  MathFormula(
    name: 'Cosine Taylor Series',
    latex: r'\cos x = \sum_{n=0}^\infty \frac{(-1)^n x^{2n}}{(2n)!} = 1 - \frac{x^2}{2!} + \frac{x^4}{4!} - \cdots',
    description: 'Infinite series expansion',
  ),
  MathFormula(
    name: 'Tangent Taylor Series',
    latex: r'\tan x = x + \frac{x^3}{3} + \frac{2x^5}{15} + \cdots \text{ (|x| < π/2)}',
    description: 'Infinite series expansion',
  ),
  MathFormula(
    name: 'Fourier Series',
    latex: r'f(x) = a_0 + \sum_{n=1}^\infty (a_n\cos nx + b_n\sin nx)',
    description: 'Periodic function representation',
  ),

  // Trigonometric Inequalities
  MathFormula(
    name: 'Jordan\'s Inequality',
    latex: r'\frac{2}{\pi}\theta \leq \sin\theta \leq \theta \text{ for } 0 \leq \theta \leq \frac{\pi}{2}',
    description: 'Bounds for sine function',
  ),
  MathFormula(
    name: 'Cosine Inequality',
    latex: r'1 - \frac{\theta^2}{2} \leq \cos\theta \leq 1 - \frac{\theta^2}{2} + \frac{\theta^4}{24} \text{ for } \theta \in \mathbb{R}',
    description: 'Bounds for cosine function',
  ),

  // Trigonometric Limits
  MathFormula(
    name: 'Fundamental Limit',
    latex: r'\lim_{\theta \to 0} \frac{\sin\theta}{\theta} = 1',
    description: 'Important trigonometric limit',
  ),
  MathFormula(
    name: 'Cosine Limit',
    latex: r'\lim_{\theta \to 0} \frac{1 - \cos\theta}{\theta} = 0',
    description: 'Important trigonometric limit',
  ),
  MathFormula(
    name: 'Tangent Limit',
    latex: r'\lim_{\theta \to 0} \frac{\tan\theta}{\theta} = 1',
    description: 'Derived from sine limit',
  ),

  // Trigonometric Derivatives
  MathFormula(
    name: 'Sine Derivative',
    latex: r'\frac{d}{dx}\sin x = \cos x',
    description: 'Derivative of sine function',
  ),
  MathFormula(
    name: 'Cosine Derivative',
    latex: r'\frac{d}{dx}\cos x = -\sin x',
    description: 'Derivative of cosine function',
  ),
  MathFormula(
    name: 'Tangent Derivative',
    latex: r'\frac{d}{dx}\tan x = \sec^2 x',
    description: 'Derivative of tangent function',
  ),
  MathFormula(
    name: 'Secant Derivative',
    latex: r'\frac{d}{dx}\sec x = \sec x \tan x',
    description: 'Derivative of secant function',
  ),
  MathFormula(
    name: 'Cosecant Derivative',
    latex: r'\frac{d}{dx}\csc x = -\csc x \cot x',
    description: 'Derivative of cosecant function',
  ),
  MathFormula(
    name: 'Cotangent Derivative',
    latex: r'\frac{d}{dx}\cot x = -\csc^2 x',
    description: 'Derivative of cotangent function',
  ),

  // Trigonometric Integrals
  MathFormula(
    name: 'Integral of Sine',
    latex: r'\int \sin x \, dx = -\cos x + C',
    description: 'Antiderivative of sine',
  ),
  MathFormula(
    name: 'Integral of Cosine',
    latex: r'\int \cos x \, dx = \sin x + C',
    description: 'Antiderivative of cosine',
  ),
  MathFormula(
    name: 'Integral of Tangent',
    latex: r'\int \tan x \, dx = -\ln|\cos x| + C',
    description: 'Antiderivative of tangent',
  ),
  MathFormula(
    name: 'Integral of Secant',
    latex: r'\int \sec x \, dx = \ln|\sec x + \tan x| + C',
    description: 'Antiderivative of secant',
  ),
  MathFormula(
    name: 'Integral of Cosecant',
    latex: r'\int \csc x \, dx = -\ln|\csc x + cot x| + C',
    description: 'Antiderivative of cosecant',
  ),
  MathFormula(
    name: 'Integral of Cotangent',
    latex: r'\int \cot x \, dx = \ln|\sin x| + C',
    description: 'Antiderivative of cotangent',
  ),
  MathFormula(
    name: 'Integral of Secant Squared',
    latex: r'\int \sec^2 x \, dx = \tan x + C',
    description: 'Antiderivative of sec²x',
  ),
  MathFormula(
    name: 'Integral of Cosecant Squared',
    latex: r'\int \csc^2 x \, dx = -\cot x + C',
    description: 'Antiderivative of csc²x',
  ),
  MathFormula(
    name: 'Integral of Secant-Tangent',
    latex: r'\int \sec x \tan x \, dx = \sec x + C',
    description: 'Antiderivative of secx tanx',
  ),
  MathFormula(
    name: 'Integral of Cosecant-Cotangent',
    latex: r'\int \csc x \cot x \, dx = -\csc x + C',
    description: 'Antiderivative of cscx cotx',
  ),

  // Inverse Trigonometric Derivatives
  MathFormula(
    name: 'Arcsine Derivative',
    latex: r'\frac{d}{dx}\arcsin x = \frac{1}{\sqrt{1 - x^2}}',
    description: 'Derivative of inverse sine',
  ),
  MathFormula(
    name: 'Arccosine Derivative',
    latex: r'\frac{d}{dx}\arccos x = -\frac{1}{\sqrt{1 - x^2}}',
    description: 'Derivative of inverse cosine',
  ),
  MathFormula(
    name: 'Arctangent Derivative',
    latex: r'\frac{d}{dx}\arctan x = \frac{1}{1 + x^2}',
    description: 'Derivative of inverse tangent',
  ),
  MathFormula(
    name: 'Arcsecant Derivative',
    latex: r'\frac{d}{dx}\arcsec x = \frac{1}{|x|\sqrt{x^2 - 1}}',
    description: 'Derivative of inverse secant',
  ),
  MathFormula(
    name: 'Arccosecant Derivative',
    latex: r'\frac{d}{dx}\arccsc x = -\frac{1}{|x|\sqrt{x^2 - 1}}',
    description: 'Derivative of inverse cosecant',
  ),
  MathFormula(
    name: 'Arccotangent Derivative',
    latex: r'\frac{d}{dx}\arccot x = -\frac{1}{1 + x^2}',
    description: 'Derivative of inverse cotangent',
  ),

  // Inverse Trigonometric Integrals
  MathFormula(
    name: 'Integral of Arcsine',
    latex: r'\int \arcsin x \, dx = x\arcsin x + \sqrt{1 - x^2} + C',
    description: 'Antiderivative of arcsin',
  ),
  MathFormula(
    name: 'Integral of Arctangent',
    latex: r'\int \arctan x \, dx = x\arctan x - \frac{1}{2}\ln(1 + x^2) + C',
    description: 'Antiderivative of arctan',
  ),
  MathFormula(
    name: 'Integral of Arcsecant',
    latex: r'\int \arcsec x \, dx = x\arcsec x - \ln\left(x + \sqrt{x^2 - 1}\right) + C',
    description: 'Antiderivative of arcsec',
  ),

  // Hyperbolic Derivatives
  MathFormula(
    name: 'Sinh Derivative',
    latex: r'\frac{d}{dx}\sinh x = \cosh x',
    description: 'Derivative of hyperbolic sine',
  ),
  MathFormula(
    name: 'Cosh Derivative',
    latex: r'\frac{d}{dx}\cosh x = \sinh x',
    description: 'Derivative of hyperbolic cosine',
  ),
  MathFormula(
    name: 'Tanh Derivative',
    latex: r'\frac{d}{dx}\tanh x = \sech^2 x',
    description: 'Derivative of hyperbolic tangent',
  ),

  // Hyperbolic Integrals
  MathFormula(
    name: 'Integral of Sinh',
    latex: r'\int \sinh x \, dx = \cosh x + C',
    description: 'Antiderivative of sinh',
  ),
  MathFormula(
    name: 'Integral of Cosh',
    latex: r'\int \cosh x \, dx = \sinh x + C',
    description: 'Antiderivative of cosh',
  ),
  MathFormula(
    name: 'Integral of Tanh',
    latex: r'\int \tanh x \, dx = \ln(\cosh x) + C',
    description: 'Antiderivative of tanh',
  ),

  // Miscellaneous
  MathFormula(
    name: 'Versine Function',
    latex: r'\text{versin }\theta = 1 - \cos\theta',
    description: 'Versed sine function',
  ),
  MathFormula(
    name: 'Haversine Formula',
    latex: r'\text{haversin }\theta = \frac{1 - \cos\theta}{2} = \sin^2\left(\frac{\theta}{2}\right)',
    description: 'Used in navigation',
  ),
  MathFormula(
    name: 'Exsecant Function',
    latex: r'\text{exsec }\theta = \sec\theta - 1',
    description: 'Exterior secant function',
  ),
  MathFormula(
    name: 'Crd Function',
    latex: r'\text{crd }\theta = 2\sin\left(\frac{\theta}{2}\right)',
    description: 'Chord length function',
  ),
  MathFormula(
    name: 'Gudermannian Function',
    latex: r'\text{gd }x = \int_0^x \sech t \, dt = 2\arctan(e^x) - \frac{\pi}{2}',
    description: 'Relates trigonometric and hyperbolic functions',
  ),
];

final List<MathFormula> calculusFormulas = [
  // Basic Derivatives
  MathFormula(
    name: 'Derivative Power Rule',
    latex: r'\frac{d}{dx}x^n = nx^{n-1}',
    description: 'Basic rule for finding derivatives of power functions',
  ),
  MathFormula(
    name: 'Derivative of Constant',
    latex: r'\frac{d}{dx}c = 0',
    description: 'Derivative of a constant is zero',
  ),
  MathFormula(
    name: 'Derivative of e^x',
    latex: r'\frac{d}{dx}e^x = e^x',
    description: 'Exponential function derivative',
  ),
  MathFormula(
    name: 'Derivative of ln(x)',
    latex: r'\frac{d}{dx}\ln(x) = \frac{1}{x}',
    description: 'Natural logarithm derivative',
  ),
  MathFormula(
    name: 'Derivative of sin(x)',
    latex: r'\frac{d}{dx}\sin(x) = \cos(x)',
    description: 'Sine function derivative',
  ),
  MathFormula(
    name: 'Derivative of cos(x)',
    latex: r'\frac{d}{dx}\cos(x) = -\sin(x)',
    description: 'Cosine function derivative',
  ),
  MathFormula(
    name: 'Derivative of tan(x)',
    latex: r'\frac{d}{dx}\tan(x) = \sec^2(x)',
    description: 'Tangent function derivative',
  ),
  MathFormula(
    name: 'Derivative of arcsin(x)',
    latex: r'\frac{d}{dx}\arcsin(x) = \frac{1}{\sqrt{1-x^2}}',
    description: 'Inverse sine derivative',
  ),
  MathFormula(
    name: 'Derivative of arctan(x)',
    latex: r'\frac{d}{dx}\arctan(x) = \frac{1}{1+x^2}',
    description: 'Inverse tangent derivative',
  ),

  // Differentiation Rules
  MathFormula(
    name: 'Sum Rule',
    latex: r"\frac{d}{dx}[f(x) + g(x)] = f\'(x) + g\'(x)",
    description: 'Derivative of a sum',
  ),
  MathFormula(
    name: 'Product Rule',
    latex: r"\frac{d}{dx}[f(x)g(x)] = f\'(x)g(x) + f(x)g\'(x)",
    description: 'Derivative of a product',
  ),
  MathFormula(
    name: 'Quotient Rule',
    latex: r"\frac{d}{dx}\left[\frac{f(x)}{g(x)}\right] = \frac{f\'(x)g(x) - f(x)g\'(x)}{g(x)^2}",
    description: 'Derivative of a quotient',
  ),
  MathFormula(
    name: 'Chain Rule',
    latex: r"\frac{d}{dx}f(g(x)) = f\'(g(x)) \cdot g\'(x)",
    description: 'Derivative of a composition',
  ),

  // Integrals
  MathFormula(
    name: 'Integral Power Rule',
    latex: r'\int x^n dx = \frac{x^{n+1}}{n+1} + C \quad (n \neq -1)',
    description: 'Basic power rule for integration',
  ),
  MathFormula(
    name: 'Integral of 1/x',
    latex: r'\int \frac{1}{x} dx = \ln|x| + C',
    description: 'Integral of reciprocal function',
  ),
  MathFormula(
    name: 'Integral of e^x',
    latex: r'\int e^x dx = e^x + C',
    description: 'Integral of exponential function',
  ),
  MathFormula(
    name: 'Integral of sin(x)',
    latex: r'\int \sin(x) dx = -\cos(x) + C',
    description: 'Integral of sine',
  ),
  MathFormula(
    name: 'Integral of cos(x)',
    latex: r'\int \cos(x) dx = \sin(x) + C',
    description: 'Integral of cosine',
  ),
  MathFormula(
    name: 'Integral of sec²(x)',
    latex: r'\int \sec^2(x) dx = \tan(x) + C',
    description: 'Integral of secant squared',
  ),
  MathFormula(
    name: 'Integral of 1/(1+x²)',
    latex: r'\int \frac{1}{1+x^2} dx = \arctan(x) + C',
    description: 'Integral leading to arctangent',
  ),
  MathFormula(
    name: 'Integral of 1/√(1-x²)',
    latex: r'\int \frac{1}{\sqrt{1-x^2}} dx = \arcsin(x) + C',
    description: 'Integral leading to arcsine',
  ),

  // Fundamental Theorems
  MathFormula(
    name: 'Fundamental Theorem of Calculus I',
    latex: r'\frac{d}{dx}\int_a^x f(t) dt = f(x)',
    description: 'First fundamental theorem',
  ),
  MathFormula(
    name: 'Fundamental Theorem of Calculus II',
    latex: r'\int_a^b f(x)dx = F(b) - F(a)',
    description: 'Second fundamental theorem',
  ),

  // Integration Techniques
  MathFormula(
    name: 'Integration by Parts',
    latex: r'\int u dv = uv - \int v du',
    description: 'Product rule in integral form',
  ),
  MathFormula(
    name: 'Substitution Rule',
    latex: r"\int f(g(x))g\'(x) dx = \int f(u) du",
    description: 'Chain rule in integral form',
  ),

  // Limits
  MathFormula(
    name: 'Limit Definition of Derivative',
    latex: r"f\'(x) = \lim_{h \to 0} \frac{f(x+h)-f(x)}{h}",
    description: 'Formal derivative definition',
  ),
  MathFormula(
    name: 'Squeeze Theorem',
    latex: r'\text{If } f(x) \leq g(x) \leq h(x) \text{ and } \lim f(x) = \lim h(x) = L, \text{ then } \lim g(x) = L',
    description: 'Theorem for evaluating tricky limits',
  ),
  
  MathFormula(
    name: 'Limit of sin(x)/x',
    latex: r'\lim_{x \to 0} \frac{\sin x}{x} = 1',
    description: 'Fundamental limit in calculus',
  ),
  MathFormula(
    name: 'Limit of sin(x)/x',
    latex: r'\lim_{x \to 0} \frac{\sin x}{x} = 1',
    description: 'Fundamental limit in calculus',
  ),
  MathFormula(
    name: 'Limit of sin(x)/x',
    latex: r'\lim_{x \to 0} \frac{\sin x}{x} = 1',
    description: 'Fundamental limit in calculus',
  ),
  MathFormula(
    name: 'Limit of sin(x)/x',
    latex: r'\lim_{x \to 0} \frac{\sin x}{x} = 1',
    description: 'Fundamental limit in calculus',
  ),
  MathFormula(
    name: 'Limit of (1 + 1/n)^n',
    latex: r'\lim_{n \to \infty} \left(1 + \frac{1}{n}\right)^n = e',
    description: 'Definition of Euler\'s number',
  ),

  // Series
  MathFormula(
    name: 'Taylor Series',
    latex: r'f(x) = \sum_{n=0}^{\infty} \frac{f^{(n)}(a)}{n!}(x-a)^n',
    description: 'Power series expansion of a function',
  ),
  MathFormula(
    name: 'Maclaurin Series for e^x',
    latex: r'e^x = \sum_{n=0}^{\infty} \frac{x^n}{n!}',
    description: 'Taylor series centered at 0 for exponential',
  ),
  MathFormula(
    name: 'Maclaurin Series for sin(x)',
    latex: r'\sin(x) = \sum_{n=0}^{\infty} (-1)^n \frac{x^{2n+1}}{(2n+1)!}',
    description: 'Taylor series for sine',
  ),
  MathFormula(
    name: 'Geometric Series',
    latex: r'\sum_{n=0}^{\infty} ar^n = \frac{a}{1-r} \text{ for } |r| < 1',
    description: 'Sum of infinite geometric series',
  ),

  // Multivariable Calculus
  MathFormula(
    name: 'Partial Derivative',
    latex: r'\frac{\partial f}{\partial x} = \lim_{h \to 0} \frac{f(x+h,y)-f(x,y)}{h}',
    description: 'Derivative with respect to one variable',
  ),
  MathFormula(
    name: 'Gradient',
    latex: r'\nabla f = \left(\frac{\partial f}{\partial x}, \frac{\partial f}{\partial y}, \frac{\partial f}{\partial z}\right)',
    description: 'Vector of partial derivatives',
  ),
  MathFormula(
    name: 'Divergence',
    latex: r'\nabla \cdot \mathbf{F} = \frac{\partial F_x}{\partial x} + \frac{\partial F_y}{\partial y} + \frac{\partial F_z}{\partial z}',
    description: 'Measure of vector field expansion',
  ),
  MathFormula(
    name: 'Curl',
    latex: r'\nabla \times \mathbf{F} = \left(\frac{\partial F_z}{\partial y} - \frac{\partial F_y}{\partial z}\right)\mathbf{i} + \left(\frac{\partial F_x}{\partial z} - \frac{\partial F_z}{\partial x}\right)\mathbf{j} + \left(\frac{\partial F_y}{\partial x} - \frac{\partial F_x}{\partial y}\right)\mathbf{k}',
    description: 'Measure of vector field rotation',
  ),
  MathFormula(
    name: 'Double Integral',
    latex: r'\iint_D f(x,y) dA',
    description: 'Integration over a 2D region',
  ),
  MathFormula(
    name: 'Polar Coordinates Conversion',
    latex: r"\iint_D f(x,y) dA = \iint_{D\'} f(r\cos\theta, r\sin\theta) r dr d\theta",
    description: 'Change of variables to polar',
  ),

  // Differential Equations
  MathFormula(
    name: 'Separable Equation',
    latex: r'\frac{dy}{dx} = f(x)g(y) \Rightarrow \int \frac{dy}{g(y)} = \int f(x) dx',
    description: 'Solution method for separable ODEs',
  ),
  MathFormula(
    name: 'Linear First-Order ODE',
    latex: r'\frac{dy}{dx} + P(x)y = Q(x) \Rightarrow y = e^{-\int P dx}\left(\int Q e^{\int P dx} dx + C\right)',
    description: 'Integrating factor method',
  ),
  MathFormula(
    name: 'Characteristic Equation',
    latex: r"ay\'\' + by\' + cy = 0 \Rightarrow ar^2 + br + c = 0",
    description: 'Solving constant coefficient linear ODEs',
  ),

  // Advanced Integration
  MathFormula(
    name: 'Arc Length',
    latex: r'L = \int_a^b \sqrt{1 + \left(\frac{dy}{dx}\right)^2} dx',
    description: 'Length of a curve y=f(x)',
  ),
  MathFormula(
    name: 'Surface Area of Revolution',
    latex: r'S = 2\pi \int_a^b y \sqrt{1 + \left(\frac{dy}{dx}\right)^2} dx',
    description: 'Surface area about x-axis',
  ),
  MathFormula(
    name: 'Volume by Disks',
    latex: r'V = \pi \int_a^b [f(x)]^2 dx',
    description: 'Volume of revolution about x-axis',
  ),
  MathFormula(
    name: 'Volume by Shells',
    latex: r'V = 2\pi \int_a^b x f(x) dx',
    description: 'Volume of revolution about y-axis',
  ),

  // Vector Calculus
  MathFormula(
    name: 'Line Integral',
    latex: r"\int_C \mathbf{F} \cdot d\mathbf{r} = \int_a^b \mathbf{F}(\mathbf{r}(t)) \cdot \mathbf{r}\'(t) dt",
    description: 'Integral of vector field along curve',
  ),
  MathFormula(
    name: 'Green\'s Theorem',
    latex: r'\oint_C (L dx + M dy) = \iint_D \left(\frac{\partial M}{\partial x} - \frac{\partial L}{\partial y}\right) dA',
    description: 'Relates line integral to double integral',
  ),
  MathFormula(
    name: 'Stokes\' Theorem',
    latex: r'\oint_C \mathbf{F} \cdot d\mathbf{r} = \iint_S (\nabla \times \mathbf{F}) \cdot d\mathbf{S}',
    description: 'Generalized Green\'s theorem',
  ),
  MathFormula(
    name: 'Divergence Theorem',
    latex: r'\oiint_S \mathbf{F} \cdot d\mathbf{S} = \iiint_V (\nabla \cdot \mathbf{F}) dV',
    description: 'Relates surface integral to volume integral',
  ),

  // More Derivatives
  MathFormula(
    name: 'Derivative of csc(x)',
    latex: r'\frac{d}{dx}\csc(x) = -\csc(x)\cot(x)',
    description: 'Cosecant derivative',
  ),
  MathFormula(
    name: 'Derivative of sec(x)',
    latex: r'\frac{d}{dx}\sec(x) = \sec(x)\tan(x)',
    description: 'Secant derivative',
  ),
  MathFormula(
    name: 'Derivative of cot(x)',
    latex: r'\frac{d}{dx}\cot(x) = -\csc^2(x)',
    description: 'Cotangent derivative',
  ),
  MathFormula(
    name: 'Derivative of a^x',
    latex: r'\frac{d}{dx}a^x = a^x \ln(a)',
    description: 'General exponential derivative',
  ),
  MathFormula(
    name: 'Derivative of log_a(x)',
    latex: r'\frac{d}{dx}\log_a(x) = \frac{1}{x \ln(a)}',
    description: 'General logarithm derivative',
  ),
  MathFormula(
    name: 'Derivative of cosh(x)',
    latex: r'\frac{d}{dx}\cosh(x) = \sinh(x)',
    description: 'Hyperbolic cosine derivative',
  ),
  MathFormula(
    name: 'Derivative of sinh(x)',
    latex: r'\frac{d}{dx}\sinh(x) = \cosh(x)',
    description: 'Hyperbolic sine derivative',
  ),

  // More Integrals
  MathFormula(
    name: 'Integral of tan(x)',
    latex: r'\int \tan(x) dx = -\ln|\cos(x)| + C',
    description: 'Integral of tangent',
  ),
  MathFormula(
    name: 'Integral of sec(x)',
    latex: r'\int \sec(x) dx = \ln|\sec(x) + tan(x)| + C',
    description: 'Integral of secant',
  ),
  MathFormula(
    name: 'Integral of csc(x)',
    latex: r'\int \csc(x) dx = -\ln|\csc(x) + \cot(x)| + C',
    description: 'Integral of cosecant',
  ),
  MathFormula(
    name: 'Integral of cot(x)',
    latex: r'\int \cot(x) dx = \ln|\sin(x)| + C',
    description: 'Integral of cotangent',
  ),
  MathFormula(
    name: 'Integral of sinh(x)',
    latex: r'\int \sinh(x) dx = \cosh(x) + C',
    description: 'Integral of hyperbolic sine',
  ),
  MathFormula(
    name: 'Integral of cosh(x)',
    latex: r'\int \cosh(x) dx = \sinh(x) + C',
    description: 'Integral of hyperbolic cosine',
  ),

  // Parametric and Polar
  MathFormula(
    name: 'Parametric Derivative',
    latex: r'\frac{dy}{dx} = \frac{dy/dt}{dx/dt}',
    description: 'Derivative for parametric equations',
  ),
  MathFormula(
    name: 'Polar Area',
    latex: r'A = \frac{1}{2} \int_{\alpha}^{\beta} [f(\theta)]^2 d\theta',
    description: 'Area bounded by polar curve',
  ),
  MathFormula(
    name: 'Arc Length (Parametric)',
    latex: r'L = \int_a^b \sqrt{\left(\frac{dx}{dt}\right)^2 + \left(\frac{dy}{dt}\right)^2} dt',
    description: 'Length of parametric curve',
  ),

  // Sequences and Series
  MathFormula(
    name: 'Ratio Test',
    latex: r'\lim_{n \to \infty} \left|\frac{a_{n+1}}{a_n}\right| = L \Rightarrow \begin{cases} L < 1 & \text{converges} \\ L > 1 & \text{diverges} \\ L = 1 & \text{inconclusive} \end{cases}',
    description: 'Test for series convergence',
  ),
  MathFormula(
    name: 'Root Test',
    latex: r'\lim_{n \to \infty} \sqrt[n]{|a_n|} = L \Rightarrow \begin{cases} L < 1 & \text{converges} \\ L > 1 & \text{diverges} \\ L = 1 & \text{inconclusive} \end{cases}',
    description: 'Alternative convergence test',
  ),
  MathFormula(
    name: 'Integral Test',
    latex: r'\text{If } f \text{ is positive, continuous, and decreasing, then } \sum_{n=1}^{\infty} a_n \text{ and } \int_1^{\infty} f(x) dx \text{ both converge or both diverge}',
    description: 'Relates series to improper integral',
  ),
  MathFormula(
    name: 'p-Series Test',
    latex: r'\sum_{n=1}^{\infty} \frac{1}{n^p} \text{ converges if } p > 1',
    description: 'Convergence of p-series',
  ),

  // Advanced Topics
  MathFormula(
    name: 'Laplace Transform',
    latex: r'\mathcal{L}\{f(t)\} = \int_0^{\infty} e^{-st} f(t) dt',
    description: 'Integral transform for differential equations',
  ),
  MathFormula(
    name: 'Fourier Series',
    latex: r'f(x) = \frac{a_0}{2} + \sum_{n=1}^{\infty} \left(a_n \cos\left(\frac{n\pi x}{L}\right) + b_n \sin\left(\frac{n\pi x}{L}\right)\right)',
    description: 'Representation of periodic functions',
  ),
  MathFormula(
    name: 'Gamma Function',
    latex: r'\Gamma(n) = \int_0^{\infty} x^{n-1} e^{-x} dx',
    description: 'Extension of factorial function',
  ),
  MathFormula(
    name: 'Beta Function',
    latex: r'B(x,y) = \int_0^1 t^{x-1} (1-t)^{y-1} dt = \frac{\Gamma(x)\Gamma(y)}{\Gamma(x+y)}',
    description: 'Special function in calculus',
  ),

  // Multivariable Derivatives
  MathFormula(
    name: 'Directional Derivative',
    latex: r'D_u f(x,y) = \nabla f(x,y) \cdot \mathbf{u}',
    description: 'Derivative in direction of unit vector u',
  ),
  MathFormula(
    name: 'Tangent Plane',
    latex: r'z = f(a,b) + f_x(a,b)(x-a) + f_y(a,b)(y-b)',
    description: 'Equation of tangent plane to surface',
  ),
  MathFormula(
    name: 'Jacobian Determinant',
    latex: r'J = \frac{\partial(x,y)}{\partial(u,v)} = \begin{vmatrix} \frac{\partial x}{\partial u} & \frac{\partial x}{\partial v} \\ \frac{\partial y}{\partial u} & \frac{\partial y}{\partial v} \end{vmatrix}',
    description: 'Used in change of variables',
  ),

  // Vector Calculus Identities
  MathFormula(
    name: 'Curl of Gradient',
    latex: r'\nabla \times (\nabla f) = 0',
    description: 'Curl of gradient is zero',
  ),
  MathFormula(
    name: 'Divergence of Curl',
    latex: r'\nabla \cdot (\nabla \times \mathbf{F}) = 0',
    description: 'Divergence of curl is zero',
  ),
  MathFormula(
    name: 'Vector Laplacian',
    latex: r'\nabla^2 \mathbf{F} = \nabla(\nabla \cdot \mathbf{F}) - \nabla \times (\nabla \times \mathbf{F})',
    description: 'Vector version of Laplacian',
  ),

  // Differential Forms
  MathFormula(
    name: 'Exact Differential',
    latex: r'M dx + N dy \text{ is exact if } \frac{\partial M}{\partial y} = \frac{\partial N}{\partial x}',
    description: 'Condition for exact differential equation',
  ),
  MathFormula(
    name: 'Total Differential',
    latex: r'df = \frac{\partial f}{\partial x} dx + \frac{\partial f}{\partial y} dy + \frac{\partial f}{\partial z} dz',
    description: 'Differential of multivariable function',
  ),

  // Numerical Methods
  MathFormula(
    name: 'Trapezoidal Rule',
    latex: r'\int_a^b f(x) dx \approx \frac{b-a}{2n} \left[f(x_0) + 2\sum_{i=1}^{n-1} f(x_i) + f(x_n)\right]',
    description: 'Numerical integration approximation',
  ),
  MathFormula(
    name: 'Simpson\'s Rule',
    latex: r'\int_a^b f(x) dx \approx \frac{b-a}{3n} \left[f(x_0) + 4\sum_{\text{odd } i} f(x_i) + 2\sum_{\text{even } i} f(x_i) + f(x_n)\right]',
    description: 'More accurate numerical integration',
  ),
  MathFormula(
    name: 'Euler\'s Method',
    latex: r'y_{n+1} = y_n + h f(t_n, y_n)',
    description: 'Numerical method for ODEs',
  ),

  // Additional Formulas
  MathFormula(
    name: 'Binomial Theorem',
    latex: r'(a+b)^n = \sum_{k=0}^{n} \binom{n}{k} a^{n-k} b^k',
    description: 'Expansion of binomial expression',
  ),
  MathFormula(
    name: 'Binomial Series',
    latex: r'(1+x)^k = \sum_{n=0}^{\infty} \binom{k}{n} x^n \text{ for } |x| < 1',
    description: 'Generalized binomial expansion',
  ),
  MathFormula(
    name: 'Cauchy-Riemann Equations',
    latex: r'\frac{\partial u}{\partial x} = \frac{\partial v}{\partial y}, \quad \frac{\partial u}{\partial y} = -\frac{\partial v}{\partial x}',
    description: 'Conditions for complex differentiability',
  ),
  MathFormula(
    name: 'Riemann Sum',
    latex: r'\int_a^b f(x) dx = \lim_{n \to \infty} \sum_{i=1}^n f(x_i^*) \Delta x',
    description: 'Formal definition of definite integral',
  ),
  
  MathFormula(
    name: 'Logarithmic Differentiation',
    latex: r'\text{If } y = f(x), \text{ then } \frac{dy}{dx} = y \cdot \frac{d}{dx}[\ln(f(x))]',
    description: 'Technique for complex derivatives',
  ),
  MathFormula(
    name: 'Implicit Differentiation',
    latex: r'\text{For } F(x,y) = 0, \quad \frac{dy}{dx} = -\frac{F_x}{F_y}',
    description: 'Derivative of implicitly defined function',
  ),
  MathFormula(
    name: 'Average Value of Function',
    latex: r'f_{\text{avg}} = \frac{1}{b-a} \int_a^b f(x) dx',
    description: 'Mean value over interval',
  ),
  MathFormula(
    name: 'Work Integral',
    latex: r'W = \int_C \mathbf{F} \cdot d\mathbf{r}',
    description: 'Work done by force field',
  ),
  MathFormula(
    name: 'Center of Mass',
    latex: r'\bar{x} = \frac{1}{A} \int_a^b x f(x) dx, \quad \bar{y} = \frac{1}{A} \int_a^b \frac{1}{2}[f(x)]^2 dx',
    description: 'Centroid formulas for planar region',
  ),
];

final List<MathFormula> statisticsFormulas = [
  // Descriptive Statistics
  MathFormula(
    name: 'Mean',
    latex: r'\bar{x} = \frac{\sum x_i}{n}',
    description: 'Average value of a dataset',
  ),
  MathFormula(
    name: 'Median',
    latex: r'\text{Median} = \begin{cases} x_{(n+1)/2} & \text{if } n \text{ is odd} \\ \frac{x_{n/2} + x_{n/2+1}}{2} & \text{if } n \text{ is even} \end{cases}',
    description: 'Middle value of ordered dataset',
  ),
  MathFormula(
    name: 'Mode',
    latex: r'\text{Mode} = \text{most frequent value}',
    description: 'Most common value in dataset',
  ),
  MathFormula(
    name: 'Population Variance',
    latex: r'\sigma^2 = \frac{\sum (x_i - \mu)^2}{N}',
    description: 'Average squared deviation from mean',
  ),
  MathFormula(
    name: 'Sample Variance',
    latex: r's^2 = \frac{\sum (x_i - \bar{x})^2}{n-1}',
    description: 'Unbiased estimator of population variance',
  ),
  MathFormula(
    name: 'Population Standard Deviation',
    latex: r'\sigma = \sqrt{\frac{\sum (x_i - \mu)^2}{N}}',
    description: 'Square root of population variance',
  ),
  MathFormula(
    name: 'Sample Standard Deviation',
    latex: r's = \sqrt{\frac{\sum (x_i - \bar{x})^2}{n-1}}',
    description: 'Square root of sample variance',
  ),
  MathFormula(
    name: 'Range',
    latex: r'\text{Range} = \max(x_i) - \min(x_i)',
    description: 'Difference between max and min values',
  ),
  MathFormula(
    name: 'Interquartile Range',
    latex: r'IQR = Q_3 - Q_1',
    description: 'Range of middle 50% of data',
  ),
  MathFormula(
    name: 'Coefficient of Variation',
    latex: r'CV = \frac{\sigma}{\mu} \times 100\%',
    description: 'Relative standard deviation',
  ),
  MathFormula(
    name: 'Z-Score',
    latex: r'z = \frac{x - \mu}{\sigma}',
    description: 'Standardized value',
  ),
  MathFormula(
    name: 'Skewness',
    latex: r'\text{Skewness} = \frac{E[(X-\mu)^3]}{\sigma^3}',
    description: 'Measure of distribution asymmetry',
  ),
  MathFormula(
    name: 'Kurtosis',
    latex: r'\text{Kurtosis} = \frac{E[(X-\mu)^4]}{\sigma^4}',
    description: 'Measure of distribution tail heaviness',
  ),
  MathFormula(
    name: 'Covariance',
    latex: r'\text{Cov}(X,Y) = \frac{\sum (x_i - \bar{x})(y_i - \bar{y})}{n-1}',
    description: 'Measure of joint variability',
  ),
  MathFormula(
    name: 'Pearson Correlation',
    latex: r'r = \frac{\text{Cov}(X,Y)}{s_X s_Y}',
    description: 'Linear correlation coefficient',
  ),
  MathFormula(
    name: 'Spearman Rank Correlation',
    latex: r'\rho = 1 - \frac{6 \sum d_i^2}{n(n^2-1)}',
    description: 'Non-parametric correlation measure',
  ),

  // Probability Basics
  MathFormula(
    name: 'Probability',
    latex: r'P(A) = \frac{\text{Number of favorable outcomes}}{\text{Total number of outcomes}}',
    description: 'Classical probability definition',
  ),
  MathFormula(
    name: 'Complement Rule',
    latex: r'P(A^c) = 1 - P(A)',
    description: 'Probability of not occurring',
  ),
  MathFormula(
    name: 'Addition Rule',
    latex: r'P(A \cup B) = P(A) + P(B) - P(A \cap B)',
    description: 'Probability of A or B occurring',
  ),
  MathFormula(
    name: 'Conditional Probability',
    latex: r'P(A|B) = \frac{P(A \cap B)}{P(B)}',
    description: 'Probability of A given B occurred',
  ),
  MathFormula(
    name: 'Multiplication Rule',
    latex: r'P(A \cap B) = P(A) \cdot P(B|A)',
    description: 'Probability of both A and B occurring',
  ),
  MathFormula(
    name: 'Independence',
    latex: r'P(A \cap B) = P(A) \cdot P(B)',
    description: 'Definition of independent events',
  ),
  MathFormula(
    name: 'Bayes\' Theorem',
    latex: r'P(A|B) = \frac{P(B|A)P(A)}{P(B)}',
    description: 'Updates probability based on new info',
  ),
  MathFormula(
    name: 'Law of Total Probability',
    latex: r'P(B) = \sum P(B|A_i)P(A_i)',
    description: 'For partition of sample space',
  ),

  // Discrete Distributions
  MathFormula(
    name: 'Bernoulli Distribution',
    latex: r'P(X=x) = p^x(1-p)^{1-x} \quad x \in \{0,1\}',
    description: 'Single trial success/failure',
  ),
  MathFormula(
    name: 'Binomial Distribution',
    latex: r'P(X=k) = \binom{n}{k} p^k (1-p)^{n-k}',
    description: 'Number of successes in n trials',
  ),
  MathFormula(
    name: 'Geometric Distribution',
    latex: r'P(X=k) = (1-p)^{k-1}p',
    description: 'Trials until first success',
  ),
  MathFormula(
    name: 'Negative Binomial',
    latex: r'P(X=k) = \binom{k-1}{r-1} p^r (1-p)^{k-r}',
    description: 'Trials until r successes',
  ),
  MathFormula(
    name: 'Poisson Distribution',
    latex: r'P(X=k) = \frac{e^{-\lambda} \lambda^k}{k!}',
    description: 'Events in fixed interval',
  ),
  MathFormula(
    name: 'Hypergeometric Distribution',
    latex: r'P(X=k) = \frac{\binom{K}{k} \binom{N-K}{n-k}}{\binom{N}{n}}',
    description: 'Successes without replacement',
  ),

  // Continuous Distributions
  MathFormula(
    name: 'Uniform Distribution',
    latex: r'f(x) = \begin{cases} \frac{1}{b-a} & a \leq x \leq b \\ 0 & \text{otherwise} \end{cases}',
    description: 'Equal probability over interval',
  ),
  MathFormula(
    name: 'Normal Distribution',
    latex: r'f(x) = \frac{1}{\sigma\sqrt{2\pi}} e^{-\frac{1}{2}\left(\frac{x-\mu}{\sigma}\right)^2}',
    description: 'Gaussian distribution',
  ),
  MathFormula(
    name: 'Standard Normal',
    latex: r'Z \sim N(0,1)',
    description: 'Normal with μ=0, σ=1',
  ),
  MathFormula(
    name: 'Exponential Distribution',
    latex: r'f(x) = \lambda e^{-\lambda x} \quad x \geq 0',
    description: 'Time between Poisson events',
  ),
  MathFormula(
    name: 'Gamma Distribution',
    latex: r'f(x) = \frac{\beta^\alpha}{\Gamma(\alpha)} x^{\alpha-1} e^{-\beta x}',
    description: 'Generalization of exponential',
  ),
  MathFormula(
    name: 'Chi-Square Distribution',
    latex: r'\chi^2_k = \sum_{i=1}^k Z_i^2 \quad Z_i \sim N(0,1)',
    description: 'Sum of squared normals',
  ),
  MathFormula(
    name: 'Student\'s t-Distribution',
    latex: r'T = \frac{Z}{\sqrt{V/k}} \quad Z \sim N(0,1), V \sim \chi^2_k',
    description: 'Small sample inference',
  ),
  MathFormula(
    name: 'F-Distribution',
    latex: r'F = \frac{U_1/d_1}{U_2/d_2} \quad U_i \sim \chi^2_{d_i}',
    description: 'Ratio of chi-squares',
  ),
  MathFormula(
    name: 'Beta Distribution',
    latex: r'f(x) = \frac{x^{\alpha-1}(1-x)^{\beta-1}}{B(\alpha,\beta)}',
    description: 'Distribution on [0,1] interval',
  ),
  MathFormula(
    name: 'Log-Normal Distribution',
    latex: r'f(x) = \frac{1}{x\sigma\sqrt{2\pi}} e^{-\frac{(\ln x - \mu)^2}{2\sigma^2}}',
    description: 'Exponentiation of normal',
  ),

  // Sampling Distributions
  MathFormula(
    name: 'Sample Mean Distribution',
    latex: r'\bar{X} \sim N\left(\mu, \frac{\sigma}{\sqrt{n}}\right)',
    description: 'CLT for sample means',
  ),
  MathFormula(
    name: 'Sample Proportion Distribution',
    latex: r'\hat{p} \sim N\left(p, \sqrt{\frac{p(1-p)}{n}}\right)',
    description: 'CLT for proportions',
  ),
  MathFormula(
    name: 't-Statistic',
    latex: r't = \frac{\bar{x} - \mu}{s/\sqrt{n}}',
    description: 'For unknown population variance',
  ),
  MathFormula(
    name: 'Chi-Square Statistic',
    latex: r'\chi^2 = \sum \frac{(O_i - E_i)^2}{E_i}',
    description: 'Goodness-of-fit test',
  ),
  MathFormula(
    name: 'F-Statistic',
    latex: r'F = \frac{\text{Between-group variance}}{\text{Within-group variance}}',
    description: 'ANOVA test statistic',
  ),

  // Confidence Intervals
  MathFormula(
    name: 'CI for Mean (σ known)',
    latex: r'\bar{x} \pm z_{\alpha/2} \frac{\sigma}{\sqrt{n}}',
    description: 'Z-interval for population mean',
  ),
  MathFormula(
    name: 'CI for Mean (σ unknown)',
    latex: r'\bar{x} \pm t_{\alpha/2,n-1} \frac{s}{\sqrt{n}}',
    description: 't-interval for population mean',
  ),
  MathFormula(
    name: 'CI for Proportion',
    latex: r'\hat{p} \pm z_{\alpha/2} \sqrt{\frac{\hat{p}(1-\hat{p})}{n}}',
    description: 'Large sample proportion interval',
  ),
  MathFormula(
    name: 'CI for Variance',
    latex: r'\left(\frac{(n-1)s^2}{\chi^2_{\alpha/2}}, \frac{(n-1)s^2}{\chi^2_{1-\alpha/2}}\right)',
    description: 'Chi-square interval for variance',
  ),
  MathFormula(
    name: 'CI for Difference of Means',
    latex: r'(\bar{x}_1 - \bar{x}_2) \pm t_{\alpha/2} \sqrt{\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}}',
    description: 'Independent samples t-interval',
  ),

  // Hypothesis Testing
  MathFormula(
    name: 'Z-Test Statistic',
    latex: r'z = \frac{\bar{x} - \mu_0}{\sigma/\sqrt{n}}',
    description: 'For known population variance',
  ),
  MathFormula(
    name: 't-Test Statistic',
    latex: r't = \frac{\bar{x} - \mu_0}{s/\sqrt{n}}',
    description: 'For unknown population variance',
  ),
  MathFormula(
    name: 'Two-Sample t-Test',
    latex: r't = \frac{(\bar{x}_1 - \bar{x}_2) - (\mu_1 - \mu_2)}{\sqrt{\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}}}',
    description: 'Comparing two means',
  ),
  MathFormula(
    name: 'Paired t-Test',
    latex: r't = \frac{\bar{d} - \mu_d}{s_d/\sqrt{n}}',
    description: 'For dependent samples',
  ),
  MathFormula(
    name: 'Chi-Square Test',
    latex: r'\chi^2 = \sum \frac{(O_i - E_i)^2}{E_i}',
    description: 'Goodness-of-fit or independence',
  ),
  MathFormula(
    name: 'ANOVA F-Test',
    latex: r'F = \frac{MS_{\text{between}}}{MS_{\text{within}}}}',
    description: 'Comparing multiple means',
  ),

  // Regression
  MathFormula(
    name: 'Simple Linear Regression',
    latex: r'y = \beta_0 + \beta_1 x + \epsilon',
    description: 'Basic regression model',
  ),
  MathFormula(
    name: 'Regression Coefficients',
    latex: r'\hat{\beta}_1 = \frac{\sum (x_i - \bar{x})(y_i - \bar{y})}{\sum (x_i - \bar{x})^2}, \quad \hat{\beta}_0 = \bar{y} - \hat{\beta}_1 \bar{x}',
    description: 'OLS estimators',
  ),
  MathFormula(
    name: 'R-Squared',
    latex: r'R^2 = \frac{SS_{\text{reg}}}{SS_{\text{tot}}} = 1 - \frac{SS_{\text{res}}}{SS_{\text{tot}}}}',
    description: 'Coefficient of determination',
  ),
  MathFormula(
    name: 'Adjusted R-Squared',
    latex: r'R^2_{\text{adj}} = 1 - \frac{(1-R^2)(n-1)}{n-p-1}',
    description: 'Penalizes for extra predictors',
  ),
  MathFormula(
    name: 'Multiple Regression',
    latex: r'y = \beta_0 + \beta_1 x_1 + \cdots + \beta_p x_p + \epsilon',
    description: 'General linear model',
  ),
  MathFormula(
    name: 'Correlation Coefficient',
    latex: r'r = \frac{n\sum xy - (\sum x)(\sum y)}{\sqrt{[n\sum x^2 - (\sum x)^2][n\sum y^2 - (\sum y)^2]}}',
    description: 'Pearson\'s r formula',
  ),

  // Nonparametric Tests
  MathFormula(
    name: 'Wilcoxon Rank-Sum',
    latex: r'W = \sum_{i=1}^{n_1} R_i',
    description: 'Mann-Whitney U test statistic',
  ),
  MathFormula(
    name: 'Kruskal-Wallis',
    latex: r'H = \frac{12}{N(N+1)} \sum \frac{R_i^2}{n_i} - 3(N+1)',
    description: 'Non-parametric ANOVA',
  ),
  MathFormula(
    name: 'Spearman\'s Rho',
    latex: r'\rho = 1 - \frac{6 \sum d_i^2}{n(n^2-1)}',
    description: 'Rank correlation coefficient',
  ),
  MathFormula(
    name: 'Kendall\'s Tau',
    latex: r'\tau = \frac{C - D}{\frac{1}{2} n(n-1)}',
    description: 'Another rank correlation measure',
  ),

  // Bayesian Statistics
  MathFormula(
    name: 'Bayesian Update',
    latex: r'P(\theta|X) = \frac{P(X|\theta)P(\theta)}{P(X)}',
    description: 'Posterior distribution',
  ),
  MathFormula(
    name: 'Conjugate Prior',
    latex: r'\text{Beta}(\alpha,\beta) \rightarrow \text{Binomial likelihood} \rightarrow \text{Beta}(\alpha+k,\beta+n-k)',
    description: 'Example of conjugate updating',
  ),
  MathFormula(
    name: 'Bayesian Credible Interval',
    latex: r'P(a \leq \theta \leq b | X) = 1 - \alpha',
    description: 'Bayesian analog of CI',
  ),

  // Time Series
  MathFormula(
    name: 'Autocorrelation',
    latex: r'\rho_k = \frac{\text{Cov}(X_t, X_{t+k})}{\text{Var}(X_t)}',
    description: 'Correlation with lagged self',
  ),
  MathFormula(
    name: 'Moving Average',
    latex: r'MA(q): X_t = \mu + \epsilon_t + \sum_{i=1}^q \theta_i \epsilon_{t-i}',
    description: 'MA model equation',
  ),
  MathFormula(
    name: 'AR(1) Model',
    latex: r'X_t = c + \phi X_{t-1} + \epsilon_t',
    description: 'First-order autoregression',
  ),

  // Multivariate Statistics
  MathFormula(
    name: 'Mahalanobis Distance',
    latex: r'D^2 = (x - \mu)^T \Sigma^{-1} (x - \mu)',
    description: 'Multivariate distance measure',
  ),
  MathFormula(
    name: 'Principal Components',
    latex: r'Y = XW \quad \text{where } W \text{ are eigenvectors of } X^TX',
    description: 'PCA transformation',
  ),

  // Quality Control
  MathFormula(
    name: 'Control Limits',
    latex: r'\text{UCL} = \mu + 3\sigma, \quad \text{LCL} = \mu - 3\sigma',
    description: '3-sigma control limits',
  ),
  MathFormula(
    name: 'Process Capability',
    latex: r'C_p = \frac{\text{USL} - \text{LSL}}{6\sigma}',
    description: 'Potential capability index',
  ),

  // Experimental Design
  MathFormula(
    name: 'Factorial Design',
    latex: r'Y_{ijk} = \mu + \alpha_i + \beta_j + (\alpha\beta)_{ij} + \epsilon_{ijk}',
    description: 'Two-way ANOVA model',
  ),
  MathFormula(
    name: 'Randomized Block',
    latex: r'Y_{ij} = \mu + \alpha_i + \beta_j + \epsilon_{ij}',
    description: 'Blocking experimental design',
  ),

  // Survival Analysis
  MathFormula(
    name: 'Kaplan-Meier Estimator',
    latex: r'\hat{S}(t) = \prod_{t_i \leq t} \left(1 - \frac{d_i}{n_i}\right)',
    description: 'Non-parametric survival function',
  ),
  MathFormula(
    name: 'Hazard Function',
    latex: r'h(t) = \lim_{\Delta t \to 0} \frac{P(t \leq T < t+\Delta t | T \geq t)}{\Delta t}',
    description: 'Instantaneous failure rate',
  ),

  // Machine Learning
  MathFormula(
    name: 'Logistic Regression',
    latex: r'P(Y=1|X) = \frac{1}{1+e^{-(\beta_0 + \beta X)}}',
    description: 'Classification model',
  ),
  MathFormula(
    name: 'Cross-Entropy Loss',
    latex: r'L = -\sum y_i \log(p_i)',
    description: 'Classification loss function',
  ),
  MathFormula(
    name: 'Gini Impurity',
    latex: r'G = 1 - \sum p_i^2',
    description: 'Decision tree splitting criterion',
  ),

  // Additional Formulas
  MathFormula(
    name: 'Moment Generating Function',
    latex: r'M_X(t) = E[e^{tX}]',
    description: 'Characterizes distribution',
  ),
  MathFormula(
    name: 'Chebyshev\'s Inequality',
    latex: r'P(|X-\mu| \geq k\sigma) \leq \frac{1}{k^2}',
    description: 'Bound on probability',
  ),
  MathFormula(
    name: 'Central Limit Theorem',
    latex: r'\frac{\bar{X}_n - \mu}{\sigma/\sqrt{n}} \xrightarrow{d} N(0,1)',
    description: 'Foundation of inference',
  ),
  MathFormula(
    name: 'Law of Large Numbers',
    latex: r'\bar{X}_n \xrightarrow{P} \mu \text{ as } n \to \infty',
    description: 'Sample means converge',
  ),
  MathFormula(
    name: 'Markov Chain Stationary Distribution',
    latex: r'\pi P = \pi',
    description: 'Long-run behavior of Markov chain',
  ),
  MathFormula(
    name: 'Bootstrap Standard Error',
    latex: r'SE_{\text{boot}} = \sqrt{\frac{1}{B-1} \sum_{b=1}^B (\hat{\theta}_b^* - \bar{\theta}^*)^2}',
    description: 'Resampling-based error estimate',
  ),
  MathFormula(
    name: 'Akaike Information Criterion',
    latex: r'AIC = 2k - 2\ln(\hat{L})',
    description: 'Model selection criterion',
  ),
  MathFormula(
    name: 'Bayesian Information Criterion',
    latex: r'BIC = k\ln(n) - 2\ln(\hat{L})',
    description: 'Alternative to AIC',
  ),
  MathFormula(
    name: 'Jensen\'s Inequality',
    latex: r'f(E[X]) \leq E[f(X)] \text{ for convex } f',
    description: 'Bound on expectations',
  ),
  MathFormula(
    name: 'Fisher Information',
    latex: r'I(\theta) = -E\left[\frac{\partial^2}{\partial \theta^2} \log f(X;\theta)\right]',
    description: 'Information about parameter',
  ),
  MathFormula(
    name: 'Cramér-Rao Bound',
    latex: r'\text{Var}(\hat{\theta}) \geq \frac{1}{I(\theta)}',
    description: 'Lower bound on variance',
  ),
];