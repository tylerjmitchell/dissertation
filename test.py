import os
os.getcwd()
os.chdir("/Users/user/Documents/dissertation/ch2")

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
# requires statsmodels 5.0 or more
from statsmodels.formula.api import ols
# ANOVA on linear models
from statsmodels.stats.anova import anova_lm

data = pd.read_csv("data.csv")
data

y = data["adjustLW"]
x = data["PC1"]

plt.figure(figsize=(5, 4))
plt.plot(x, y, 'o')
plt.show()

model = ols("y ~ x", data).fit()
print(model.summary())
anova_results = anova_lm(model)
print('\nANOVA results')
print(anova_results)

# retrieve parameter estimates
offset, coef = model._results.params
plt.plot(x, x*coef + offset)
plt.xlabel('x')
plt.ylabel('y')

plt.show()