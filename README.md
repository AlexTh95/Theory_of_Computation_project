# Theory_of_Computation_project
Project of the class "Theory of Computation" from Electrical and Computer Engineering Department of Technical University of Crete.


Language - Fictional C

TOKENS

  ● Keywords:

   static    true   do       if   not 
   boolean   false  break    else and
   integer   string continue for  mod
   character void   return   end  real
   while     begin

  ● Identifiers wich are used for variable, function, or class names and consist of a small or capital letter followed by                  zero or more letters, numbers or underscores.

  ● Integer positive constants

  ● Real positive constants 

  ● Boolean constants: true / false

  ● Constant characters: can be any character or escape sequence(\n, \t, \r, \\, \', \") in single quotation marks ('').

  ● Constant strings: a string in double quotation marks (" ").

  ● Operators: Arithmetic: + - * / mod
               Relational: = >= <= > < !=
               Logical: and or not && || !
               Assignment :=
               Sign: + -

  ● Separators: begin end ; ( ) , [ ] 

  ● White space: series consist of space, tab, line feed or carriage return.

  ● Comments

  ● Line comments


SYNTAX

  ● Programm: -Variable declaration
                     -Function declaration (necessary to declare integer main())
                     
  ● Data types: ● integer ● boolean ● character ● real ● string
           
  ● Variable declaration: type identifier1, identifier2, ..., identifierk;
                          type identifier[n][m]...[k];
                                 
  ● Functions: type title (type identifier1, type identifier2, ..., type identifierk)
                          begin
                               body
                          end
                             
  ● Expressions
           
  ● Commands: -Blank command (;)
              -Complex command: begin <sequence of commands> end
              -Assignment command: v := e;, where v is a variable and e is an exression.
              -Control command: if (e) s1 else s2, where e is an expression and s1,s2 are sequences of commands.
              -Repeat command: for (s1;e;s2) s, where s1,s1 are simple commands, e is an expression and s a sequence of commands.
              -Loop command: while (e) s 
                             do s while (e); , e is an expression and s a sequence of commands.
              -Break command: break;
              -Continue command: continue;
              -Return command: return;
              -Call function command: f(e1 ,...,en );, where f is a function name, e are expressions.
                                    







