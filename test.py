

import pandas as pd
import numpy as np

# Create sample data
letter_grades = pd.DataFrame({
    'grade': ['A', 'B', 'B', 'C', 'F']
})

letter_grades

# TO do: recode
# Recode A, B, C to Pass, F to Fail

# You can define a dictionary to map the values
grade_map = {'A': 'Pass', 'B': 'Pass', 'C': 'Pass', 'F': 'Fail'}

letter_grades['grade_points'] = letter_grades['grade'].replace(grade_map)
letter_grades

# You could also do it directly without predefining the dictionary
letter_grades['grade_points'] = letter_grades['grade'].replace({'A': 'Pass', 'B': 'Pass', 'C': 'Pass', 'F': 'Fail'})
letter_grades



# Including NAs (typically missing data)

letter_grades_na = pd.DataFrame({
    'grade': ['A', 'B', 'B', 'C', np.nan, 'F']
})

# TO do: recode A B C to Pass, F to Fail, np.nan to Missing

grade_map_na = {'A': 'Pass', 'B': 'Pass', 'C': 'Pass', 'F': 'Fail', np.nan: 'Missing'}

letter_grades_na['grade_points'] = letter_grades_na['grade'].replace(grade_map_na)
letter_grades_na


# Recoding numeric data with custom functions and use apply
# Below 3 is "Fail", between 3 and 8 is "Pass", 8 and above is "Distinction", np.nan is "No grade"
# (you could use cut, but in my experience, students make lots of mistakes with cut. Better to be explicit)


## Need to actually teach the students how to define functions cuz I haven't done that yet.
num_grades = pd.DataFrame({
    'grade': [1, 5, 2, 3, 10, 7, np.nan]
})  

def grade_recoder(g):
    if g < 3:
        return 'Fail'
    elif g >= 3 and g < 8:
        return 'Pass'
    elif g >= 8:    
        return 'Distinction'
    elif np.isnan(g):
        return 'No grade'
    else:
        return 'No match'

num_grades['grade_points'] = num_grades['grade'].apply(grade_recoder)
num_grades