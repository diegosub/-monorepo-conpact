import { Agrupador, AgrupadorAlterarDto, AgrupadorInserirDto } from '@admin/domain';
import { AgrupadorService, JwtAuthGuard } from '@admin/services';
import { Body, Controller, Get, Param, Post, Put, Query, UseGuards, UsePipes, ValidationPipe } from '@nestjs/common';


@Controller('agrupador')
@UseGuards(JwtAuthGuard)
export class AgrupadorController {

  constructor(
    private readonly service: AgrupadorService
  ) { }

  @Get(':codigo')
  async get(@Param('codigo') codigo: number): Promise<Agrupador> {
    return await this.service.getById(codigo);
  }

  @Get()
  async pesquisar(@Query() filtros: Agrupador): Promise<Agrupador[]> {
    return await this.service.pesquisar(filtros);
  }

  @Post()
  @UsePipes(new ValidationPipe({ transform: true }))
  async inserir(@Body() agrupadorDto : AgrupadorInserirDto): Promise<Agrupador> {
    const agrupador: Agrupador = new Agrupador();
    Object.assign(agrupador, agrupadorDto);
    agrupador.dataInclusao = new Date();
    agrupador.ativo = true;
    return await this.service.inserir(agrupador);
  }

  @Put(':codigo')
  @UsePipes(new ValidationPipe({ transform: true }))
  async alterar(@Param('codigo') codigo: string, @Body() agrupadorDto: AgrupadorAlterarDto): Promise<Agrupador> {
    const agrupador: any = {codigo: codigo};
    Object.assign(agrupador, agrupadorDto);
    agrupador.dataAlteracao = new Date();
    return await this.service.alterar(agrupador);
  }

  @Put('/inativar/:codigo')
  async inativar(@Param('codigo') codigo: number): Promise<Agrupador> {
    return await this.service.inativar(codigo);
  }

  @Put('ativar/:codigo')
  async ativar(@Param('codigo') codigo: number): Promise<Agrupador> {
    return await this.service.ativar(codigo);
  }
}
