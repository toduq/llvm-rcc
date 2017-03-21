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
		when :statement then
			id = build_ir(ast[:value], ir, scope)
			ir << "call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i32 %#{id})"
			ir << "ret i32 %#{id}"
			ir
		when :integer_constant then
			ir << "%#{scope[:var_id]} = alloca i32, align 4"
			ir << "store i32 #{ast[:value]}, i32* %#{scope[:var_id]}, align 4"
			ir << "%#{scope[:var_id]+1} = load i32, i32* %#{scope[:var_id]}, align 4"
			scope[:var_id] += 2
			scope[:var_id] - 1
		when :operator then
			left_id = build_ir(ast[:left], ir, scope)
			right_id = build_ir(ast[:right], ir, scope)
			case ast[:value]
			when '+' then
				ir << "%#{scope[:var_id]} = add nsw i32 %#{left_id}, %#{right_id}"
			when '-' then
				ir << "%#{scope[:var_id]} = sub nsw i32 %#{left_id}, %#{right_id}"
			when '*' then
				ir << "%#{scope[:var_id]} = mul nsw i32 %#{left_id}, %#{right_id}"
			when '/' then
				ir << "%#{scope[:var_id]} = sdiv i32 %#{left_id}, %#{right_id}"
			end
			scope[:var_id] += 1
			scope[:var_id] - 1
		end
	end

	private
	def default_scope
		{
			var_id: 1
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