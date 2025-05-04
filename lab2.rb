require 'json'
require 'yaml'


expenses = []

def add_expense(expenses, amount, categories, payment_methods, description)
  expenses << {
    id: expenses.size + 1,
    amount: amount,
    categories: categories,
    payment_methods: payment_methods,
    description: description,
    date: Time.now.strftime("%Y-%m-%d %H:%M:%S")
  }
end


def edit_expense(expenses, id, new_data)
  expense = expenses.find { |e| e[:id] == id }
  return puts "Expense not found." unless expense

  expense.merge!(new_data)
end


def delete_expense(expenses, id)
  expenses.reject! { |e| e[:id] == id }
end


def list_expenses(expenses)
  expenses.each do |expense|
    puts "ID: #{expense[:id]}, Amount: #{expense[:amount]}, Categories: #{expense[:categories].join(', ')}, Payment: #{expense[:payment_methods].join(', ')}, Description: #{expense[:description]}"
  end
end


def save_to_file(expenses, filename, format)
  data = format == 'json' ? JSON.pretty_generate(expenses) : YAML.dump(expenses)
  File.write(filename, data)
  puts "Data saved to #{filename}."
end


def load_from_file(expenses, filename, format)
  return puts "File not found." unless File.exist?(filename)

  file_content = File.read(filename)
  expenses.replace(format == 'json' ? JSON.parse(file_content, symbolize_names: true) : YAML.load(file_content))
  puts "Data loaded from #{filename}."
end


def menu(expenses)
  loop do
    puts "\nExpense Manager Menu:"
    puts "1. Add Expense"
    puts "2. Edit Expense"
    puts "3. Delete Expense"
    puts "4. List Expenses"
    puts "5. Save to File"
    puts "6. Load from File"
    puts "7. Exit"
    print "Choose an option: "

    case gets.chomp.to_i
    when 1
      print "Amount: "; amount = gets.chomp.to_f
      print "Categories (comma-separated): "; categories = gets.chomp.split(', ')
      print "Payment Methods (comma-separated): "; payment_methods = gets.chomp.split(', ')
      print "Description: "; description = gets.chomp
      add_expense(expenses, amount, categories, payment_methods, description)
      puts "Expense added."
    when 2
      print "Expense ID to edit: "; id = gets.chomp.to_i
      print "New Amount (or press enter to skip): "; amount = gets.chomp
      print "New Categories (comma-separated, or enter to skip): "; categories = gets.chomp.split(', ')
      print "New Payment Methods (comma-separated, or enter to skip): "; payment_methods = gets.chomp.split(', ')
      print "New Description (or press enter to skip): "; description = gets.chomp
      new_data = {}
      new_data[:amount] = amount.to_f unless amount.empty?
      new_data[:categories] = categories unless categories.empty?
      new_data[:payment_methods] = payment_methods unless payment_methods.empty?
      new_data[:description] = description unless description.empty?
      edit_expense(expenses, id, new_data)
    when 3
      print "Expense ID to delete: "; id = gets.chomp.to_i
      delete_expense(expenses, id)
      puts "Expense deleted."
    when 4
      list_expenses(expenses)
    when 5
      print "Filename: "; filename = gets.chomp
      print "Format (json/yaml): "; format = gets.chomp
      save_to_file(expenses, filename, format)
    when 6
      print "Filename: "; filename = gets.chomp
      print "Format (json/yaml): "; format = gets.chomp
      load_from_file(expenses, filename, format)
    when 7
      puts "Exiting..."
      break
    else
      puts "Invalid option. Try again."
    end
  end
end


menu(expenses)
