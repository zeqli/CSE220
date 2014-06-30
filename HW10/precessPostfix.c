#include<stdio.h>

ProcessPostfix(char* str){
	char* token;
	int secondOperand;
	int firstOperand;
	int result;
	while((*str)!=null){
		token = getNextToken(str);
		if(isOperator(token)){
			secondOperand = stack.pop();
			firstOperand = stack.pop();
			result = eval(token, firstOperand, secondOperand);
			stack.push(result);
		}
		else{
			int num = atoi(token);
			stack.push(num);
		}
	}
	return stack.pop();
}

// helper
int isOperator(char* str){
	if(strlen(str)!=1)
		return 0;
	else if((*str)=='+') // 43
		return 1;
	else if((*str)=='-') // 45
		return 1;
	else if((*str)=='*') // 42
		return 1;
	else if((*str)=='/') // 47
		return 1;
	else if((*str)=='<') // 60
		return 1;
	else if((*str)=='>') // 62
		return 1	
}

int eval(char* token, int op_1, int op_2){
	else if((*str)=='+') // 43
		return add(op_1, op_2);
	else if((*str)=='-') // 45
		return sub(op_1, op_2);
	else if((*str)=='*') // 42
		return mult(op_1, op_2);
	else if((*str)=='/') // 47
		return div(op_1, op_2);
	else if((*str)=='<') // 60
		return shift_left(op_1, op_2);
	else if((*str)=='>') // 62
		return shift_right(op_1, op_2);	
}

ProcessInfix(char* str){
	char* token = nextToken();
	while(token!=null){
		
		if(is_number(token)){
			queue.add(token);
		}
		else if(isOperator(token)){
		o1 = token;
		o2 = stack.peek;
			while(o2 is operator&& (!'^')||(precedence(o2,o1)>=0){
				char* temp = stack.pop();
				queue.add(temp);
			}
			stack.push(o1);
		}
		else if(isLeftParenthesis(token)){
			stack.push();
		}
		else if(isRightParenthesis(token)){
			char temp = stack.pop();
			while(!isLeftParenthesis(temp)&&temp!=null){
				queue.add(temp);
				temp = stack.pop();
			}
		}
	}
	while(!stack.isEmpty()){
		char* temp = stack.pop();
		queue.add(temp);
	}
}


main(){
	
}
