var FAQStringsModel = Backbone.Model.extend({
	defaults: {
		'dialogTitle': 'FAQ',
		'answerStr': 'Resposta:',
		'questionStr': 'Pergunta:',
		'questionList': [
			{
				'question': 'Não consigo logar no sistema.',
				'answer': 'Verifique se suas credenciais do PUC Online estão corretas. Caso positivo, verifique se seu navegador está configurado para aceitar COOKIES.'
			},
			{
				'question': 'O que significa cada cor na tabela de falta-cursar?',
				'answer': 'Vermelho: disciplina presa por algum pré-requisito;\nAmarelo: disciplina que você está cursando ou que está presa por algum pré-requisito que você está cursando;\nBranco: você está "apto" a cursar. Sugerimos verificar ementa no site da PUC para comprovar aptidão.\nAzul: disciplina selecionada. Suas turmas estão sendo exibidas;'
			},
			{
				'question': 'Como adiciono turma?',
				'answer': 'Basta clicar na turma em questão.'
			},
			{
				'question': 'Como removo turma?',
				'answer': 'Clique nela novamente.\nOu então a visualize na aba de selecionadas e clique no botão "x".'
			},
			{
				'question': 'Como sei que a turma foi inserida?',
				'answer': 'É apresentada uma notificação na aba de selecionadas e aparece na tabela de horarios em cores sempre distintas.'
			},
			{
				'question': 'Como adiciono disciplinas que não estão no meu falta cursar?',
				'answer': 'Basta procurar a turma na aba de micro horário e clicar na disciplina e depois na turma desejada.'
			},
			{
				'question': 'O que fazer na tela de selecionada?',
				'answer': 'Você pode fazer o que quiser, basicamente. Tanto trocar as turmas de posição movendo-as para um lugar vazio, quanto trocando-as de lugar com alguma outra. Assim como também é possível trocar as linhas de ordem.'
			},
			{
				'question': 'Mas por que isso é importante?',
				'answer': 'Porque o PUC Online funciona assim. Ao fazer o processamento das disciplinas, as disciplinas mais prioritárias serão aquelas que estão nas primeiras linhas e primeiras opções. Desta maneira, você pode trocar a prioridade de todas as turmas escolhidas simplesmente arrastando elas para onde você quiser.'
			},
			{
				'question': 'Ok, mas e daí?',
				'answer': 'Daí que você pode usar a magica funcionalidade dos radio buttons, apresentados logo do lado esquerdo de cada lugar que pode receber uma turma. Esses radio buttons representam a turma que foi possível de pegar na simulação.'
			},
			{
				'question': 'Simulação? Como funciona?',
				'answer': 'Tem por objetivo simular o que pode acontecer com a sua solicitação de matrícula no PUC Online.\nTendo conhecimento da priorização das primeiras linhas e primeiras opções, a simulação tenta sempre pegar as turmas nesse sentido do processamento. Isto é, você pode simular as opções que serão pegas em cada linha. Automaticamente será realizada uma cascata nas linhas menos prioritárias de forma a mostrar o que realmente aconteceria caso aquela opção fosse pega.'
			},
			{
				'question': 'Legal. Montei minha grade, e agora?',
				'answer': 'Infelizmente sua grade está salva em nosso sistema, mas não no PUC Online. Você deve entrar com os dados que foram gerados aqui no sistema de requisição de matrícula acadêmica, que fica localizado dentro do PUC Online.'
			},
			{
				'question': 'O sistema apresenta erros / não funciona no meu navegador.',
				'answer': 'Infelizmente o sistema foi desenvolvido tirando proveito de recursos não suportados por browsers muito antigos. Recomendo a utilização da versão mais recente do seu browser favorito. Não esqueça de nos notificar o bug para que possamos tentar consertá-lo; utilize o campo de sugestões para tal\n\Obs: o site pode estar não completamente funcional no Internet Explorer. Recomendamos o uso de algum outro navegador popular disponível atualmente. Aqueles que recomendamos são: Google Chrome, Mozilla Firefox, Opera.'
			}
		]
	}
});

var faqStringsModel = new FAQStringsModel();
