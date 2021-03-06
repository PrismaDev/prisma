var TermStringsModel = Backbone.Model.extend({
	defaults: {
		'acceptCheckboxLabel': 'Eu aceito o termo de compromisso do PrISMA',
		'cancelButtonLabel': 'Não aceito',
		'acceptButtonLabel': 'Eu li e aceitei o termo de compromisso',
		'termText': 'Termo de Compromisso\n\n \
\tDeclaro que estou ciente que o sistema PrISMA não tem nenhuma responsabilidade \
quantos às grades geradas nele, assim como não se responsabiliza por possíveis \
erros que ele permitiu o usuário cometer. Também declaro ter conhecimento dos \
seguintes ítens:\n\n \
1/ Apenas alunos regularmente matriculados na PUC-Rio podem utilizar \
este sistema. A autenticação é a mesma do PUConline. \
\n\n \
2/ O uso do PrISMA por parte de alunos da PUC-Rio é opcional. Alunos \
podem efetivar sua 1a fase de matrícula diretamente pelo PUConline, sem \
auxílio do PrISMA. \
\n\n \
3/ O sistema PrISMA auxilia na montagem de 3 opções de matrícula do \
aluno da PUC-Rio, usando as informações do histórico, contemplando o \
"Falta Cursar", disciplinas que o aluno está cursando no atual período e \
também as disciplinas já concluídas com sucesso. \
\n\n \
4/ Importantíssimo: o PrISMA não realiza a matrícula em si! Após usar o \
sistema, o aluno precisa obrigatoriamente utilizar o PUConline e entrar \
com as opções propostas após utilizar o PrISMA. Não há como importar as \
escolhas definidas após utilização do PrISMA diretamente para o \
PUConline, trata-se de uma ação a ser realizada manualmente por cada aluno. \
\n\n \
5/ O uso do sistema PrISMA não garante nem aumenta as chances do aluno \
da PUC-Rio conseguir matrícula em uma ou mais das disciplinas oferecidas \
para o próximo semestre. Também não há como garantir que o resultado \
final do PrISMA de cada aluno corresponda à melhor solução possível para \
grade de horários do próximo semestre. \
\n\n \
6/ Na versão atual, o PrISMA verifica pré-requisitos básicos e permite \
orientar o aluno para matrículas em disciplinas que ele PODE CURSAR. \
Assim, o aluno perceberá que para algumas disciplinas não é permitida a \
escolha para alguma opção - caso não tenha pré-requisitos, por exemplo - \
ou então há um aviso de atenção para disciplinas sendo cursadas, pois \
uma vez o aluno aprovado não poderá solicitar na matrícula, ou ainda, \
pode ser alguma disciplina pré-requisito de outra. \
\n\n \
7/ O PrISMA não garante que você está apto a cursar todas as turmas \
escolhidas. Isso ocorre pois as turmas podem ser destinadas a certos cursos \
e esse tipo de checagem não está sendo feita nessa versão.'
	}
});

var termStringsModel = new TermStringsModel();
