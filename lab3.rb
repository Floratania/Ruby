require 'json'
require 'yaml'

class Expense
  attr_accessor :id, :amount, :categories, :payment_methods, :description, :date

  def initialize(id, amount, categories, payment_methods, description)
    @id = id
    @amount = amount
    @categories = categories
    @payment_methods = payment_methods
    @description = description
    @date = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  end

  def to_h
    {
      id: @id,
      amount: @amount,
      categories: @categories,
      payment_methods: @payment_methods,
      description: @description,
      date: @date
    }
  end
end

class ExpenseManager
  attr_accessor :expenses

  AVAILABLE_CATEGORIES = ['Food', 'Transport', 'Utilities', 'Entertainment', 'Health', 'Other']
  AVAILABLE_PAYMENT_METHODS = ['Cash', 'Card', 'Bank Transfer', 'Mobile Payment', 'Other']

  def initialize
    @expenses = []
  end

  def add_expense(amount, categories, payment_methods, description)
    id = @expenses.size + 1
    expense = Expense.new(id, amount, categories, payment_methods, description)
    @expenses << expense
    puts "✅ Expense added."
  end

  def edit_expense(id, new_data)
    expense = @expenses.find { |e| e.id == id }
    return puts "⚠️ Expense not found." unless expense

    expense.amount = new_data[:amount] if new_data[:amount]
    expense.categories = new_data[:categories] if new_data[:categories]
    expense.payment_methods = new_data[:payment_methods] if new_data[:payment_methods]
    expense.description = new_data[:description] if new_data[:description]

    puts "✅ Expense updated."
  end

  def delete_expense(id)
    if @expenses.reject! { |e| e.id == id }
      puts "Expense deleted."
    else
      puts "Expense not found."
    end
  end

  def list_expenses
    if @expenses.empty?
      puts "No expenses recorded."
    else
      @expenses.each do |e|
        puts " ID: #{e.id}, Amount: $#{e.amount}, Categories: #{e.categories.join(', ')}, Payment: #{e.payment_methods.join(', ')}, Description: #{e.description}, Date: #{e.date}"
      end
    end
  end

  def save_to_file(filename, format)
    data = @expenses.map(&:to_h)
    output = format == 'json' ? JSON.pretty_generate(data) : YAML.dump(data)
    File.write(filename, output)
    puts " Data saved to #{filename}."
  end

  def load_from_file(filename, format)
    return puts "❌ File not found." unless File.exist?(filename)

    content = File.read(filename)
    data = format == 'json' ? JSON.parse(content, symbolize_names: true) : YAML.load(content)
    @expenses = data.map do |h|
      Expense.new(h[:id], h[:amount], h[:categories], h[:payment_methods], h[:description])
    end
    puts "📂 Data loaded from #{filename}."
  end

  def choose_categories
    puts "📂 Choose categories (comma-separated numbers) or enter your own:"
    AVAILABLE_CATEGORIES.each_with_index { |cat, i| puts "#{i + 1}. #{cat}" }
    print "Your choice (or custom categories): "
    input = gets.chomp
    if input =~ /^\d+(,\s*\d+)*$/
      choices = input.split(',').map(&:strip).map(&:to_i)
      choices.map { |i| AVAILABLE_CATEGORIES[i - 1] }.compact
    else
      input.split(',').map(&:strip)
    end
  end

  def choose_payment_methods(default = [])
    puts "💳 Choose payment method(s) (comma-separated numbers):"
    AVAILABLE_PAYMENT_METHODS.each_with_index { |pm, i| puts "#{i + 1}. #{pm}" }
    print "Your choice (default: #{default.join(', ')}): "
    input = gets.chomp
    return default if input.strip.empty?
    choices = input.split(',').map(&:strip).map(&:to_i)
    choices.map { |i| AVAILABLE_PAYMENT_METHODS[i - 1] }.compact
  end
end

# ---------- Головне меню ----------
def menu
  manager = ExpenseManager.new

  loop do
    puts "\n📌 Expense Manager Menu:"
    puts "1️  Add Expense"
    puts "2️  Edit Expense"
    puts "3️  Delete Expense"
    puts "4️  List Expenses"
    puts "5️  Save to File"
    puts "6️  Load from File"
    puts "7️  Exit"
    print "👉 Choose option: "

    case gets.chomp.to_i
    when 1
      print " Amount: "; amount = gets.chomp.to_f
      categories = manager.choose_categories
      payment_methods = manager.choose_payment_methods(['Cash', 'Card'])
      print " Description: "; description = gets.chomp
      manager.add_expense(amount, categories, payment_methods, description)
    when 2
      print " Expense ID to edit: "; id = gets.chomp.to_i
      print "New Amount (or enter to skip): "; amount_input = gets.chomp
      print "New Categories (numbers or text, or skip): "; cat_input = gets.chomp
      puts "Edit Payment Methods? (y/n): "
      edit_pm = gets.chomp.downcase
      new_pm = edit_pm == 'y' ? manager.choose_payment_methods : []
      print "New Description (or skip): "; desc = gets.chomp

      new_data = {}
      new_data[:amount] = amount_input.to_f unless amount_input.empty?
      unless cat_input.empty?
        if cat_input =~ /^\d+(,\s*\d+)*$/
          indexes = cat_input.split(',').map(&:strip).map(&:to_i)
          new_data[:categories] = indexes.map { |i| ExpenseManager::AVAILABLE_CATEGORIES[i - 1] }
        else
          new_data[:categories] = cat_input.split(',').map(&:strip)
        end
      end
      new_data[:payment_methods] = new_pm unless new_pm.empty?
      new_data[:description] = desc unless desc.empty?
      manager.edit_expense(id, new_data)
    when 3
      print "🗑️ Expense ID to delete: "; id = gets.chomp.to_i
      manager.delete_expense(id)
    when 4
      manager.list_expenses
    when 5
      print "📁 Filename: "; filename = gets.chomp
      print "Format (json/yaml): "; format = gets.chomp.downcase
      manager.save_to_file(filename, format)
    when 6
      print "📁 Filename: "; filename = gets.chomp
      print "Format (json/yaml): "; format = gets.chomp.downcase
      manager.load_from_file(filename, format)
    when 7
      puts " Goodbye!"
      break
    else
      puts "❌ Invalid choice."
    end
  end
end

menu
