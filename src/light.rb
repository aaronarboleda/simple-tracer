class Light
  ATTEN_COEFF_CONSTANT = 0.1
  ATTEN_COEFF_LINEAR = 0.05
  ATTEN_COEFF_QUADRATIC = 0.01

  def self.attenuate(distance)
    # attenuate by polynomial formula 1.0 / A + B*dL + C*dL^2
    denominator =
      ATTEN_COEFF_CONSTANT +
      ATTEN_COEFF_LINEAR * distance +
      ATTEN_COEFF_QUADRATIC * distance * distance

    1.0 / denominator
  end
end
