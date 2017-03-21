class Compiler
	attr_reader :ast, :ir

	def initialize(ast)
		@ast = ast
		@ir = []
	end

	def compile
		header
		build_ir(@ast, @ir, default_scope)
		footer
		self
	end

	def build_ir(ast, ir, scope=nil)
		case ast[:type]
		# controls
		when :compound_statement then
			id = ast[:list].map{|statement|
				build_ir(statement, ir, scope)
			}.last
			ir << "call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i32 %#{id})"
			ir << "ret i32 %#{id}"
		when :statement then
			build_ir(ast[:value], ir, scope)
		# constants
		when :integer_constant then
			ir << "%#{scope[:reg_id]} = alloca i32, align 4"
			ir << "store i32 #{ast[:value]}, i32* %#{scope[:reg_id]}, align 4"
			ir << "%#{scope[:reg_id]+1} = load i32, i32* %#{scope[:reg_id]}, align 4"
			scope[:reg_id] += 2
			scope[:reg_id] - 1
		when :variable then
			"#{ast[:name]}_#{scope[:vars][ast[:name]]}"
		# operators
		when :operator then
			left_id = build_ir(ast[:left], ir, scope)
			right_id = build_ir(ast[:right], ir, scope)
			case ast[:value]
			when '+' then
				ir << "%#{scope[:reg_id]} = add nsw i32 %#{left_id}, %#{right_id}"
			when '-' then
				ir << "%#{scope[:reg_id]} = sub nsw i32 %#{left_id}, %#{right_id}"
			when '*' then
				ir << "%#{scope[:reg_id]} = mul nsw i32 %#{left_id}, %#{right_id}"
			when '/' then
				ir << "%#{scope[:reg_id]} = sdiv i32 %#{left_id}, %#{right_id}"
			else
				raise "not implemented operator #{ast[:value]}"
			end
			scope[:reg_id] += 1
			scope[:reg_id] - 1
		# memories
		when :declaration then
			case ast[:type_name]
			when 'int'
				scope[:vars][ast[:name]] = 1
				ir << "%#{ast[:name]} = alloca i32, align 4"
				unless ast[:value].nil?
					id = build_ir(ast[:value], ir, scope)
					ir << "store i32 %#{id}, i32* %#{ast[:name]}, align 4"
					ir << "%#{ast[:name]}_1 = load i32, i32* %#{ast[:name]}, align 4"
				end
			else
				raise "not implemented declaration type #{ast[:type_name]}"
			end
		end
	end

	private
	def default_scope
		{
			reg_id: 1,
			vars: {}
		}
	end
	def header
		@ir << '@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1'
		@ir << "define i32 @main() #0 {"
	end

	def footer
		@ir << "}"
		@ir << "declare i32 @printf(i8*, ...) #1"
	end
end