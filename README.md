# Terraform CD

Esse template prepara o ambiente para um deploy continuo, criando um trigger no cloud build conectado a um repositório remoto. A seguir irei listar os passos da criação.

- Criação da custom role com as permissões mínimas necessárias.
- Criação da service account que será utilizada no cloud build.
- Adiciona a service account ao projeto.
- Cria a secret para armazenar o token do github.
- Armazena o valor do token dentro da secret.
- Da a permissão necessária a conta de serviço padrão do cloud build para acessar a secret.
- Cria policy para controle de acesso a secret.
- Cria a conexão com o github e cloud build.
- Adiciona o repositório a instalação do github.
- Cria a conexão entre a conta do github e o repositório.
- Cria o trigger vinculando o repositório e a service account criada. 

## 1. Pré-requisitos

Antes de começar, você precisará:
- **Terraform** instalado: [Instalação do Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli).
- Autenticar com o Google Cloud.
- É necessário que já haja uma instalação entre o cloud build e seu github.
- Crie um token no github sem data de expiração, com as seguintes permissões "repo" e "read:user" caso seja uma organização certifique-se de também marcar a opção "read:org" 


- ** Separe as env necessárias para a criação, project_id, instalation_id, github_token, repository_uri e repository_name

## 2. Iniciar um Novo Projeto

1. **Clone o repositório ou crie um novo diretório:**
   ```bash
   git clone <URL_DO_REPOSITORIO>
   cd <NOME_DO_DIRETORIO>
   ```

2. **Inicialize o Terraform:**
   ```bash
   terraform init
   ```
   Este comando baixa e instala os provedores necessários definidos no arquivo `main.tf`.

## 3. Configurar Variáveis

1. **Edite o arquivo `variables.tf`:**
   - Adicione ou modifique as variáveis necessárias para sua infraestrutura.

2. **Crie um arquivo `terraform.tfvars`:**
   ```bash
   touch terraform.tfvars
   ```
   - Neste arquivo, você pode definir os valores das variáveis de forma segura.

   **Exemplo:**
   ```hcl
   project_id = "meu-projeto-id"
   region     = "us-central1"
   ```

## 4. Planejar a Infraestrutura

1. **Executar o comando `terraform plan`:**
   ```bash
   terraform plan
   ```
   Este comando gera um plano de execução mostrando o que será criado, modificado ou destruído.

2. **Revisar o plano:** 
   - Confirme que as mudanças estão de acordo com o que você deseja.

## 5. Aplicar as Mudanças

1. **Execute o comando `terraform apply`:**
   ```bash
   terraform apply
   ```
   **Nota:** Este comando executa o plano gerado e realiza as mudanças na infraestrutura.

2. **Confirme a aplicação:**
   - Quando solicitado, digite `yes` para confirmar.

## 6. Limpar Infraestrutura (Opcional)

1. **Para destruir os recursos criados:**
   ```bash
   terraform destroy
   ```
   **Nota:** Use este comando com cuidado, pois ele remove todos os recursos gerenciados pelo Terraform.

## 7. Gerenciar o Estado

1. **Para visualizar o estado atual:**
   ```bash
   terraform show
   ```

2. **Para fazer backup do estado:**
   - Considere armazenar o estado em um bucket remoto para segurança e colaboração.

## 8. Referências

- [Documentação Oficial do Terraform](https://registry.terraform.io/)
