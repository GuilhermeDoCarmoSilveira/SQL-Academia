create database academia

go

use academia

go

create table aluno (
	codigo	int identity(1,1),
	nome varchar(100)
	primary key (codigo)
)

go

create table atividade (
	codigo int not null,
	descricao varchar(100),
	imc	decimal(7,2)
	primary key (codigo)
)

go

create table atividadeAluno (
	codigo int not null identity(1,1),
	codigoAluno	int null,
	codigoAtividade int not null,
	altura decimal(7,2),
	peso decimal(7,2),
	imc decimal(7,2)
	primary key (codigo)
	foreign key (codigoAluno) references aluno (codigo),
	foreign key (codigoAtividade) references atividade (codigo)
)

go

INSERT INTO atividade (codigo, descricao, imc) VALUES
(1, 'Corrida + Step', 18.5),
(2, 'Biceps + Costas + Pernas', 24.9),
(3, 'Esteira + Biceps + Costas + Pernas', 29.9),
(4, 'Bicicleta + Biceps + Costas + Pernas', 34.9),
(5, 'Esteira + Bicicleta', 39.9);


go

--drop procedure sp_AlunoAtividades

create procedure sp_AlunoAtividades(@nome varchar(100), @codAluno int, @altura decimal(7, 2), 
									@peso decimal(7, 2), @saida VARCHAR(100) OUTPUT)
as
	declare @imc decimal(7,2), @imctab decimal(7,2), @cod int, @imcfirst decimal(7,2), 
	@imclast decimal(7,2), @condicao bit, @codAtividade int

	if(@peso is null or @altura is null)begin

		RAISERROR('o peso ou altura é nulo', 16, 1)

	end else begin

		set @imc = @peso / POWER(@altura, 2)

	end

	set @cod = 2
	set @condicao = 1
	set @imcfirst = (select top 1 imc from atividade)
	set @imclast = (select top 1 imc from atividade order by imc desc)

	--set @imc = 33.0 /*Teste para testar imc*/ 

	if(@imc <= @imcfirst) begin

		set @codAtividade = (select codigo from atividade where imc = @imcfirst)

	end
		else if(@imc >= @imclast) begin

				set @codAtividade = (select codigo from atividade where imc = @imclast)

		end else begin
				while(@condicao = 1) begin
					set @imctab = (SELECT imc
					FROM (
						 SELECT imc, ROW_NUMBER() OVER (ORDER BY imc asc) AS linha
						FROM atividade
					) AS tabela_numerada
 					WHERE linha = @cod)

				if(@imc <= @imctab) begin
					set @codAtividade = (select codigo from atividade where imc = @imctab)
					set @condicao = 0
				end else begin
					set @cod = @cod + 1
				end
			end
		end
		


	if(@codAluno is null and @nome is not null
	   and @altura is not null and @peso is not null)begin

	   insert into aluno values (@nome)
	   set @codAluno = (SELECT codigo FROM aluno WHERE codigo = SCOPE_IDENTITY())

	   insert into atividadeAluno values (@codAluno, @codAtividade, @altura, @peso, @imc)

	   SET @saida = 'Aluno cadastrado com sucesso'
		
	end else if(@codAluno is not null and @altura is not null and @peso is not null) begin
		
		declare @verificaAluno int
		set @verificaAluno = null
		set @verificaAluno = (select codigo from aluno where codigo = @codAluno)
			
		if(@verificaAluno is not null)begin
			
			update atividadeAluno set codigoAluno = @codAluno, codigoAtividade = @codAtividade, altura = @altura,
									  peso = @peso, imc = @imc where codigoAluno = @codAluno

			set @saida = 'Aluno atualizado com sucesso'

		end else begin

			RAISERROR('O nome nao foi inserido', 16, 1) 

		end

	end else begin

		RAISERROR('Verifique os dados da procedure', 16, 1) 

	end

select * from atividade 
select * from aluno
select * from atividadeAluno
	
DECLARE @out1 VARCHAR(100)
EXEC sp_AlunoAtividades 'Leandro Colevati', null, 1.59, null, @out1 OUTPUT
PRINT @out1

