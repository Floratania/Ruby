require 'json'
require 'yaml'

expenses = []

AVAILABLE_CATEGORIES = ['Food', 'Transport', 'Utilities', 'Entertainment', 'Health', 'Other']
AVAILABLE_PAYMENT_METHODS = ['Cash', 'Card', 'Bank Transfer', 'Mobile Payment', 'Other']

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
  return puts " Expense not found." unless expense

  expense.merge!(new_data)
  puts "✅ Expense updated."
end

def delete_expense(expenses, id)
  if expenses.reject! { |e| e[:id] == id }
    puts " Expense deleted."
  else
    puts " Expense not found."
  end
end

def list_expenses(expenses)
  if expenses.empty?
    puts "📭 No expenses recorded."
  else
    expenses.each do |expense|
      puts "🧾 ID: #{expense[:id]}, Amount: $#{expense[:amount]}, Categories: #{expense[:categories].join(', ')}, Payment: #{expense[:payment_methods].join(', ')}, Description: #{expense[:description]}, Date: #{expense[:date]}"
    end
  end
end

def save_to_file(expenses, filename, format)
  data = format == 'json' ? JSON.pretty_generate(expenses) : YAML.dump(expenses)
  File.write(filename, data)
  puts " Data saved to #{filename}."
end

def load_from_file(expenses, filename, format)
  return puts "❌ File not found." unless File.exist?(filename)

  file_content = File.read(filename)
  expenses.replace(format == 'json' ? JSON.parse(file_content, symbolize_names: true) : YAML.load(file_content))
  puts " Data loaded from #{filename}."
end

def choose_categories
  puts " Choose categories (comma-separated numbers) or enter your own:"
  AVAILABLE_CATEGORIES.each_with_index do |category, index|
    puts "#{index + 1}. #{category}"
  end
  print "Your choice (or custom categories): "
  input = gets.chomp
  if input =~ /^\d+(,\s*\d+)*$/
    choices = input.split(',').map(&:strip).map(&:to_i)
    selected = choices.map { |i| AVAILABLE_CATEGORIES[i - 1] }.compact
    selected.empty? ? ['Other'] : selected
  else
    input.split(',').map(&:strip)
  end
end

def choose_payment_methods(default = [])
  puts "💳 Choose payment method(s) (comma-separated numbers):"
  AVAILABLE_PAYMENT_METHODS.each_with_index do |method, index|
    puts "#{index + 1}. #{method}"
  end
  print "Your choice (default: #{default.join(', ')}): "
  input = gets.chomp
  if input.strip.empty? && !default.empty?
    return default
  end
  choices = input.split(',').map(&:strip).map(&:to_i)
  selected = choices.map { |i| AVAILABLE_PAYMENT_METHODS[i - 1] }.compact
  selected.empty? ? ['Other'] : selected
end

def menu(expenses)
  loop do
    puts "\n📌 Expense Manager Menu:"
    puts "1️.  Add Expense"
    puts "2️.  Edit Expense"
    puts "3️.  Delete Expense"
    puts "4️.  List Expenses"
    puts "5️.  Save to File"
    puts "6️.  Load from File"
    puts "7️.  Exit"
    print "👉 Choose an option (enter the number of what you chose): "

    case gets.chomp.to_i
    when 1
      print " Amount: "; amount = gets.chomp.to_f
      categories = choose_categories
      payment_methods = choose_payment_methods(['Cash', 'Card'])
      print " Description: "; description = gets.chomp
      add_expense(expenses, amount, categories, payment_methods, description)
      puts " Expense added."
    when 2
      print " Expense ID to edit: "; id = gets.chomp.to_i
      print "New Amount (or enter to skip): "; amount = gets.chomp
      print "New Categories (numbers or text, or enter to skip): "; categories_input = gets.chomp
      puts "Edit Payment Methods? (y/n): "
      edit_payment = gets.chomp.downcase
      new_payment_methods = edit_payment == 'y' ? choose_payment_methods : []
      print "New Description (or enter to skip): "; description = gets.chomp

      new_data = {}
      new_data[:amount] = amount.to_f unless amount.empty?
      unless categories_input.empty?
        if categories_input =~ /^\d+(,\s*\d+)*$/
          choices = categories_input.split(',').map(&:strip).map(&:to_i)
          new_data[:categories] = choices.map { |i| AVAILABLE_CATEGORIES[i - 1] }.compact
        else
          new_data[:categories] = categories_input.split(',').map(&:strip)
        end
      end
      new_data[:payment_methods] = new_payment_methods unless new_payment_methods.empty?
      new_data[:description] = description unless description.empty?

      edit_expense(expenses, id, new_data)
    when 3
      print "🗑️ Expense ID to delete: "; id = gets.chomp.to_i
      delete_expense(expenses, id)
    when 4
      list_expenses(expenses)
    when 5
      print "📁 Filename: "; filename = gets.chomp
      print "Format (json/yaml): "; format = gets.chomp.downcase
      save_to_file(expenses, filename, format)
    when 6
      print "📁 Filename: "; filename = gets.chomp
      print "Format (json/yaml): "; format = gets.chomp.downcase
      load_from_file(expenses, filename, format)
    when 7
      puts " Exiting... Goodbye!"
      break
    else
      puts " Invalid option. Try again."
    end
  end
end

menu(expenses)
