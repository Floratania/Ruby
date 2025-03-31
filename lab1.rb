require 'json'
require 'yaml'

expenses = []

def add_expense(expenses, amount, category, payment_methods, description)
  expense = {
    id: (expenses.empty? ? 1 : expenses.last[:id] + 1),
    amount: amount,
    category: category,
    payment_methods: payment_methods,
    description: description,
    date: Time.now.strftime("%Y-%m-%d %H:%M:%S")
  }
  expenses << expense
  puts "Expense added successfully!"
end

def edit_expense(expenses, id, new_data)
  expense = expenses.find { |e| e[:id] == id }
  if expense
    expense.merge!(new_data)
    puts "Expense updated successfully!"
  else
    puts "Expense not found."
  end
end

def delete_expense(expenses, id)
  expenses.reject! { |e| e[:id] == id }
  puts "Expense deleted successfully!"
end

def search_expenses(expenses, search_term)
  results = expenses.select { |e| e[:category].include?(search_term) || e[:description].include?(search_term) }
  results.empty? ? (puts "No expenses found.") : (puts results)
end

def filter_expenses_by_category(expenses, category)
  filtered = expenses.select { |e| e[:category] == category }
  filtered.empty? ? (puts "No expenses in this category.") : (puts filtered)
end

def filter_expenses_by_payment(expenses, payment)
  filtered = expenses.select { |e| e[:payment_methods].include?(payment) }
  filtered.empty? ? (puts "No expenses with this payment method.") : (puts filtered)
end

def save_to_json(expenses, file)
  File.write(file, expenses.to_json)
  puts "Expenses saved to #{file}."
end

def load_from_json(expenses, file)
  if File.exist?(file)
    expenses.replace(JSON.parse(File.read(file), symbolize_names: true))
    puts "Expenses loaded from #{file}."
  else
    puts "File not found."
  end
end

def save_to_yaml(expenses, file)
  File.write(file, expenses.to_yaml)
  puts "Expenses saved to #{file}."
end

def load_from_yaml(expenses, file)
  if File.exist?(file)
    expenses.replace(YAML.safe_load(File.read(file), symbolize_names: true))
    puts "Expenses loaded from #{file}."
  else
    puts "File not found."
  end
end

def generate_statistics(expenses)
  stats = expenses.group_by { |e| e[:category] }
                  .transform_values { |list| list.sum { |e| e[:amount] } }
  puts "Expense statistics by category:"
  stats.each { |category, total| puts "#{category}: $#{total}" }
end

# Example usage
add_expense(expenses, 50, "Food", ["Credit Card"], "Lunch at a cafe")
add_expense(expenses, 100, "Transport", ["Cash"], "Taxi fare")
add_expense(expenses, 200, ["Shopping", "Clothing"], ["Debit Card"], "New shoes")
add_expense(expenses, 1500, ["Electronics", "Work"], ["Credit Card", "Installment"], "Laptop purchase")
add_expense(expenses, 300, ["Entertainment", "Movies"], ["Cash", "Gift Card"], "Cinema tickets with friends")
add_expense(expenses, 80, ["Groceries", "Supermarket"], ["Credit Card"], "Weekly grocery shopping")
add_expense(expenses, 400, ["Health", "Gym"], ["Bank Transfer"], "Gym membership fee")

generate_statistics(expenses)
save_to_json(expenses, "expenses.json")
