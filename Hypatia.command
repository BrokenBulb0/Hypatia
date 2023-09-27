#!/usr/bin/env python3.11

import tkinter as tk
from tkinter import ttk
import random
import os

# Constants
OPERATORS = ['+', '-', '*', '/']
MIN_DIGITS = 1
MAX_DIGITS = 6
SIMILARITY_MULTIPLIER = 3

class MathExerciseGenerator:
    def __init__(self):
        self.generated_equations = set()

    def remove_trailing_zeros(self, formatted_value):
        return formatted_value.rstrip('0').rstrip('.') if '.' in formatted_value else formatted_value

    def generate_values(self, num_values, num_digits, decimal_comma):
        if decimal_comma == "Ninguna":
            max_value = 10 ** num_digits
            values = [random.randint(1, max_value) for _ in range(num_values)]
        else:
            values = [random.uniform(1, 10 ** num_digits) for _ in range(num_values)]

        if decimal_comma == "Decimal":
            values = [f"{val:.1f}" for val in values]
        elif decimal_comma == "Centesimal":
            values = [f"{val:.2f}" for val in values]

        return values

    def generate_equation(self, values):
        operation = random.choice(OPERATORS)
        equation = f"{values[0]}"
        for i in range(1, len(values)):
            equation += f" {operation} {values[i]}"
        return equation

    def evaluate_equation(self, equation):
        try:
            result = eval(equation)
            result = round(result, 2)
            result = result if result % 1 else int(result)
            return result
        except ZeroDivisionError:
            return None

    def generate_math_problem(self, num_values, num_digits, decimal_comma, use_multiple_choice, similarity_level, difficulty_level, include_squared, include_rooted, include_cubic):
        while True:
            values = self.generate_values(num_values, num_digits, decimal_comma)
            equation = self.generate_equation(values)
            result = self.evaluate_equation(equation)

            if difficulty_level == 1:
                operators = ['+', '-']
            elif difficulty_level == 5:
                operators = OPERATORS
            else:
                operators = OPERATORS

            operation = random.choice(operators)

            if include_squared and random.choice([True, False]):
                value_index = random.randint(0, num_values - 1)
                values[value_index] = f"({values[value_index]})²"
                equation = self.generate_equation(values)

            if include_rooted and random.choice([True, False]):
                value_index = random.randint(0, num_values - 1)
                values[value_index] = f"√({values[value_index]})"
                equation = self.generate_equation(values)

            if include_cubic and random.choice([True, False]):
                value_index = random.randint(0, num_values - 1)
                values[value_index] = f"({values[value_index]})³"
                equation = self.generate_equation(values)

            if (
                result is not None
                and result != 0
                and isinstance(result, (int, float))
                and equation not in self.generated_equations
            ):
                self.generated_equations.add(equation)

                if use_multiple_choice:
                    answer_options, correct_option = self.generate_multiple_choice_options(
                        result, similarity_level, decimal_comma
                    )
                else:
                    answer_options = [result]
                    correct_option = 0

                formatted_result = format(result, ".2f") if decimal_comma != "Ninguna" else str(int(result))
                return equation, formatted_result, answer_options, correct_option

    def generate_multiple_choice_options(self, correct_answer, similarity_level, decimal_comma):
        options = []

        num_similar_options = max(1, int(similarity_level * SIMILARITY_MULTIPLIER))

        formatted_correct_answer = format(correct_answer, ".2f") if decimal_comma != "Ninguna" else str(int(correct_answer))
        options.append(formatted_correct_answer)

        while len(options) < 4:
            option_random = correct_answer + random.uniform(-10, 10)
            option_random = round(option_random, 2) if decimal_comma != "Ninguna" else int(option_random)
            formatted_option = format(option_random, ".2f") if decimal_comma != "Ninguna" else str(option_random)
            if formatted_option not in options:
                options.append(formatted_option)

        random.shuffle(options)

        correct_option = options.index(formatted_correct_answer)

        # Label the answer options as A), B), C), and D)
        labeled_options = [f"{chr(65+i)}) {option}" for i, option in enumerate(options)]

        return labeled_options, correct_option

class HypatiaApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Gupta")
        self.math_generator = MathExerciseGenerator()

        script_directory = os.path.dirname(os.path.abspath(__file__))

        self.use_multiple_choice = tk.BooleanVar()
        self.include_squared = tk.BooleanVar()
        self.include_rooted = tk.BooleanVar()
        self.include_cubic = tk.BooleanVar()
        self.difficulty_level = tk.StringVar()

        self.create_ui()

    def create_ui(self):
        ttk.Label(self.root, text="Número de preguntas:").grid(row=0, column=0)
        self.num_questions = ttk.Entry(self.root)
        self.num_questions.grid(row=0, column=1)

        ttk.Label(self.root, text="Número de valores por pregunta:").grid(row=1, column=0)
        self.num_values = ttk.Combobox(self.root, values=["2", "3", "4", "5"])
        self.num_values.grid(row=1, column=1)
        self.num_values.set("2")

        ttk.Label(self.root, text="Número de dígitos en los valores:").grid(row=2, column=0)
        self.num_digits = ttk.Combobox(self.root, values=["1", "2", "3", "4", "5", "6", "Ninguna"])
        self.num_digits.grid(row=2, column=1)
        self.num_digits.set("2")

        ttk.Label(self.root, text="Coma:").grid(row=3, column=0)
        self.decimal_comma = ttk.Combobox(self.root, values=["Ninguna", "Decimal", "Centesimal"])
        self.decimal_comma.grid(row=3, column=1)
        self.decimal_comma.set("Decimal")

        ttk.Label(self.root, text="Nivel de similitud entre respuestas (0-1):").grid(row=4, column=0)
        self.similarity_level = ttk.Entry(self.root)
        self.similarity_level.grid(row=4, column=1)
        self.similarity_level.insert(0, "0.5")

        ttk.Label(self.root, text="Dificultad (1-5):").grid(row=5, column=0)
        self.difficulty_level_combo = ttk.Combobox(self.root, values=["1", "2", "3", "4", "5"])
        self.difficulty_level_combo.grid(row=5, column=1)
        self.difficulty_level_combo.set("3")

        ttk.Checkbutton(self.root, text="Generar preguntas de opción múltiple", variable=self.use_multiple_choice).grid(row=6, column=0, columnspan=2)
        ttk.Checkbutton(self.root, text="Incluir preguntas con valores al cuadrado", variable=self.include_squared).grid(row=7, column=0, columnspan=2)
        ttk.Checkbutton(self.root, text="Incluir preguntas con valores radicales", variable=self.include_rooted).grid(row=8, column=0, columnspan=2)
        ttk.Checkbutton(self.root, text="Incluir preguntas con valores cúbicos", variable=self.include_cubic).grid(row=9, column=0, columnspan=2)

        ttk.Button(self.root, text="Generar Guía", command=self.generate_guide).grid(row=10, column=0, columnspan=2)

        self.output_text = tk.Text(self.root, wrap=tk.WORD, width=40, height=10)
        self.output_text.grid(row=11, column=0, columnspan=2)

    def show_message(self, message, clear_input=False):
        self.output_text.delete(1.0, tk.END)
        self.output_text.insert(tk.END, message)

        if clear_input:
            self.num_questions.delete(0, tk.END)

    def validate_inputs(self):
        try:
            num_questions = int(self.num_questions.get())

            if num_questions <= 0:
                raise ValueError("El número de preguntas debe ser mayor que cero.")

            num_values = int(self.num_values.get())
            num_digits_input = self.num_digits.get()

            if num_digits_input == "Ninguna":
                num_digits = None
            else:
                num_digits = int(num_digits_input)

            decimal_comma = self.decimal_comma.get()
            use_multiple_choice = self.use_multiple_choice.get()
            similarity_level = float(self.similarity_level.get())

            if not (0 <= similarity_level <= 1):
                raise ValueError("Debe estar entre 0 y 1.")

            difficulty_level = int(self.difficulty_level_combo.get())
            if not (1 <= difficulty_level <= 5):
                raise ValueError("La dificultad debe estar entre 1 y 5.")

            return num_questions, num_values, num_digits, decimal_comma, use_multiple_choice, similarity_level, difficulty_level

        except ValueError as e:
            self.show_message(f"Error: {str(e)}", clear_input=True)
            return None

    def generate_guide(self):
        inputs = self.validate_inputs()

        if inputs:
            num_questions, num_values, num_digits, decimal_comma, use_multiple_choice, similarity_level, difficulty_level = inputs

            script_directory = os.path.dirname(os.path.abspath(__file__))

            guide = ""

            for question_number in range(1, num_questions + 1):
                equation, result, answer_options, correct_option = self.math_generator.generate_math_problem(num_values, num_digits, decimal_comma, use_multiple_choice, similarity_level, difficulty_level, self.include_squared.get(), self.include_rooted.get(), self.include_cubic.get())

                formatted_question = f"{question_number}. {equation} =\n"

                if use_multiple_choice:
                    formatted_options = "\n".join([f"{chr(65+i)}) {option}" for i, option in enumerate(answer_options)])
                    formatted_options += "\n\n"
                else:
                    formatted_options = f"Answer: {result}\n\n"

                guide += formatted_question + formatted_options

            output_file = os.path.join(script_directory, "Guía_Matematicas.txt")
            with open(output_file, "w", encoding="utf-8") as file:
                file.write(guide)

            self.show_message(f"Guía generada con {num_questions} preguntas y guardada como 'Guía_Matematicas.txt'.", clear_input=True)

if __name__ == "__main__":
    root = tk.Tk()
    app = HypatiaApp(root)
    root.mainloop()
