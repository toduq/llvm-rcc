require 'llvm'
require 'llvm/core'

class Compiler
	include LLVM

	attr_reader :ast, :mod

	def initialize(ast)
		@ast = ast

		@mod = Module.new("rcc")
		@main = @mod.functions.add("main", [], Int)
		@main_block = @main.basic_blocks.append
		@main_builder = Builder.new
		@main_builder.position_at_end(@main_block)
	end

	def compile
		header
		build_ir(@ast, default_scope)
		footer
		self
	end

	def build_ir(ast, scope)
		case ast[:type]
		# controls
		when :compound_statement then
			ast[:list].each do |statement|
				build_ir(statement, scope)
			end
		when :statement then
			build_ir(ast[:value], scope)
		when :return then
			value = build_ir(ast[:value], scope)
			pointer = @main_builder.global_string("%d\n")
			pointer = @main_builder.pointer_cast(pointer, Pointer(LLVM::Int8))
			@main_builder.call(@printf, pointer, value)
			@main_builder.ret(value)
		# constants
		when :integer_constant then
			LLVM::Int(ast[:value])
		when :variable then
			@main_builder.load(scope[:vars][ast[:name]])
		# operators
		when :operator then
			left_value = build_ir(ast[:left], scope) unless ast[:value] == '='
			right_value = build_ir(ast[:right], scope)
			case ast[:value]
			when '+' then
				@main_builder.add(left_value, right_value)
			when '-' then
				@main_builder.sub(left_value, right_value)
			when '*' then
				@main_builder.mul(left_value, right_value)
			when '/' then
				@main_builder.sdiv(left_value, right_value)
			when '=' then
				@main_builder.store(right_value, scope[:vars][ast[:left]])
				right_value
			else
				raise "not implemented operator #{ast[:value]}"
			end
		# memories
		when :declaration then
			case ast[:type_name]
			when 'int'
				pointer = @main_builder.alloca(Int, ast[:name])
				scope[:vars][ast[:name]] = pointer
				if ast.has_key?(:value)
					var = build_ir(ast[:value], scope)
					@main_builder.store(var, scope[:vars][ast[:name]])
					var
				end
			else
				raise "not implemented declaration type #{ast[:type_name]}"
			end
		end
	end

	private
	def default_scope
		{
			vars: {}
		}
	end
	def header
		@printf = @mod.functions.add("printf", [Pointer(LLVM::Int8)], Int, varargs: true)
	end

	def footer
	end
end